class Nurse
  include Mongoid::Document
  include ActiveModel::SecurePassword 

  field :username
  field :admin, type: Boolean, default: false
  field :validator, type: Boolean, default: false
  field :first_name
  field :last_name
  field :password_digest

  validates :username, presence: true, uniqueness:true
  has_secure_password

  has_many :completed_procs
  belongs_to :nurse

  def procs_I_submitted
     CompletedProc.all(nurse_id: self.id, status: CompletedProc::PENDING)
  end
  alias_method :pending_procs, :procs_I_submitted

  def rejected_procs
    CompletedProc.all(nurse_id: self.id, status: CompletedProc::REJECTED)
  end

  def completed_procs_summary
    summary = {}
    Procedure.all.each do |proc|
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

  def validate_by_id(completed_proc_ids)
    self.validate(CompletedProc.in _id: completed_proc_ids)
  end

  def validate(completed_procs)
    raise "ordinary nurse tried to validate a proc!!" unless self.validator?
    completed_procs.each do |i|
      i.validate
      i.save
    end
  end


end # class
