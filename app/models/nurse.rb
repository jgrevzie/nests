



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
  validates :email, presence: true

  has_secure_password

  def role; (self.validator?) ? :validator : :default end
  def first_name; name.split[0] end
  def last_name; name.split[-1] end

  def pendings
     CompletedProc.all(nurse_id: self.id, status: CP::PENDING).desc(:date)
  end
  alias_method :pending_procs, :pendings

  def rejected_procs
    CompletedProc.all(nurse_id: self.id, status: CompletedProc::REJECTED).desc(:date)
  end
  alias_method :rejects, :rejected_procs

  def completed_procs_summary *args
    options = args.extract_options!
    summary = {}
    Procedure.asc(:name).each do |proc|
      count = 0
      CompletedProc.where(options.merge(
        nurse_id: self.id, 
        proc_id: proc.id, 
        status: CompletedProc::VALID)).each {|cp| count += cp.quantity}
      summary[proc.name] = count.to_i unless count==0
    end
    return summary
  end

  def completed_procs_total *args
    # Inefficient!
    completed_procs_summary(*args).values.inject(0, :+)
  end

  def procs_i_can_validate
    procs = Procedure.where(dept_id: self.dept.id).map(&:id)
    CP.where(status: CP::PENDING).in(proc_id: procs)
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

  def vdate_all ; vdate self.procs_i_can_vdate end

  def self.send_all_pending_validation_mails
    Nurse.where(validator: true, wants_mail: true).each do |n| 
      DailyValidations.pending_validations_mail(n).deliver
    end
  end

end # class
