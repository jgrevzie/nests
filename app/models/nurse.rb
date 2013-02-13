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
  has_many :validatees, :class_name => 'Nurse'
  belongs_to :nurse

  def procs_needing_validation
     CompletedProc.all(nurse_id: self._id, validated: false)
  end

  def all_validatee_procs_pending_validation
    self.validatees.inject([]) { |result, el| result << el.procs_needing_validation } .flatten(1) || []
  end

  def validate_procs(proc_ids)
    proc_ids.each do |id|
      cproc = CompletedProc.find id
      # skip nurses that this head nurse can't validate
      next unless self.validatees.include? cproc.nurse
       cproc.validated = true
      cproc.save
   end
 end

end
