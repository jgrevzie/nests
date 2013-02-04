class Nurse
  include Mongoid::Document
  include ActiveModel::SecurePassword 

  field :username
  field :admin, type: Boolean
  field :validator, type: Boolean
  field :first_name
  field :last_name
  field :password_digest

  validates :username, presence: true, uniqueness:true
  has_secure_password

  has_many :completed_procs
  has_many :validatees, :class_name => 'Nurse'
  belongs_to :nurse

  def procs_needing_validation
    CompletedProcs.where(
      :nurse_id => self._id,
      :validated => false)
  end

  def procs_pending_validation
    self.validatees.inject([]) { |result, el| result << el.procs_needing_validation }
  end

end
