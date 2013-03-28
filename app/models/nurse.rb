




require 'csv'
class String
  def lc_alpha; self ? self.downcase.gsub(/[^a-z]/, '') : '' end
end   

class Nurse
  include Mongoid::Document
  include ActiveModel::SecurePassword 

  field :username
  field :validator, type: Boolean, default: false
  field :name
  field :password_digest
  field :comments
  field :designation
  field :email
  field :wants_mail, type: Boolean

  has_many :completed_procs, dependent: :delete, autosave: true
  has_many :validations, class_name: 'CompletedProc'
  belongs_to :dept
 
  validates :username, presence: true, uniqueness:true
  validates :name, presence: true
  validates :dept, presence: true
  has_secure_password

  def role; (self.validator?) ? :validator : :default end
  def first_name; name.split[0] end
  def last_name; name.split[-1] end

  def procs_I_submitted
     CompletedProc.all(nurse_id: self.id, status: CompletedProc::PENDING).desc(:date_start)
  end
  alias_method :pending_procs, :procs_I_submitted

  def rejected_procs
    CompletedProc.all(nurse_id: self.id, status: CompletedProc::REJECTED).desc(:date_start)
  end

  def completed_procs_summary
    summary = {}
    Procedure.asc(:name).each do |proc|
      count = 0
      CompletedProc.where(nurse_id: self.id, 
                          procedure_id: proc.id, 
                          status: CompletedProc::VALID).each do |cp|
        count += cp.quantity
      end
      summary[proc.name] = count.to_i 
    end
    return summary
  end

  def completed_procs_total
    completed_procs_summary.values.inject :+
  end

  def validate_by_id(completed_proc_ids)
    self.vdate(CompletedProc.in _id: completed_proc_ids)
  end

  def vdate(completed_procs)
    raise "ordinary nurse tried to validate a proc!!" unless self.validator?
    completed_procs.each do |i|
      i.vdate self
      i.save
    end
  end

  def self.send_all_pending_validation_mails
    Nurse.where(validator: true, wants_mail: true).each do |n| 
      DailyValidations.pending_validations_mail(n).deliver
    end
  end

  def self.load_nurses_from_spreadsheet(file_name)
    dept1 = Fabricate :dept, name: 'CathLab', hospital: "St V's Private", location: 'Vict'
    dept2 = Fabricate :dept, name: 'Theatre', hospital: "St V's Private", location: 'Vict'

    csv = CSV.foreach(file_name, headers: true) do |row|
      fn, ln = row['name'].split[0].lc_alpha, row['name'].split[-1].lc_alpha
      row['username'] = fn[0] + ln unless row['username']
      row['validator'] = row['validator'] ? row['validator'].downcase.start_with?('y', 't') : false
      row['email'] = "#{fn}.#{ln}@svpm.org.au" unless row['email']
      row['password'] = 'password'
      
      # CSV::Row needs to be converted to hash
      n = Fabricate :nurse, row.to_hash.merge(dept: dept1)
      50.times { n.completed_procs << Fabricate(:random_completed_proc) }
    end
  end

end # class
