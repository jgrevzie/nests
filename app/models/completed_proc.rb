



class CompletedProc
	include Mongoid::Document

	MAX_PROCS_PER_DAY = 20
	OLDEST_NEW_PROC = Date.today-10

	PENDING = 'pending'
	VALID = 'valid'
	REJECTED = 'rejected'
	INVALID = REJECTED
	ACK_REJECT = 'ack_reject'
	ACK_REJECTED = ACK_REJECT

	SCRUBBED= 'Scrubbed'
	SCOUT= 'Scout'
	TECH= 'Tech'
	ROLES = [SCRUBBED, SCOUT, TECH]

	attr_accessor :check_date

	field :comments
	field :date_start, type: Date, default: Date.current
	field :quantity, type: Integer, default: 1
	field :options
	field :status, default: PENDING
	field :emergency, type: Boolean, default: false
	field :role

	belongs_to :procedure
	belongs_to :nurse, inverse_of: :completed_procs
	belongs_to :validated_by, inverse_of: :validations, class_name: 'Nurse'

	validates :quantity, numericality: { greater_than_or_equal_to: 1,
																			 less_than_or_equal_to: MAX_PROCS_PER_DAY }
	validates :procedure, presence: { message: "isn't known to CliniTraq" }
	validates :status, inclusion: { in: [PENDING, VALID, REJECTED, ACK_REJECT], 
																	message: 'unknown' }
	validates :date_start, timeliness: { before: Date.today+2, after: OLDEST_NEW_PROC },
												 if: :check_date
	validates :validated_by, presence: true, if: 'status==REJECTED || status==VALID'
	validates :options, presence: {message: "must be selected for this type of procedure."}, 
											if: 'procedure && procedure.options && procedure.options.length>0'
	validates :role, presence: true

 	attr_protected :status

	def proc_name=(proc_name) self.procedure = Procedure.where(name: proc_name).first end

	def proc_name ; self.procedure.name if self.procedure end

	def update_status(status, nurse)
		self.status = status
		self.validated_by = nurse
		self
	end
	alias_method :set_status, :update_status

	def vdate(nurse) self.update_status VALID, nurse end
	def vdated? ; self.status == VALID end

	def reject(nurse) self.update_status REJECTED, nurse end
	def rejected? ; self.status == REJECTED end

	def self.pending_validations ; CompletedProc.where(status: PENDING) end

	def ack_reject ; self.status = ACK_REJECT end
	def ackd? ; self.status == ACK_REJECT end

	class << CompletedProc
		alias_method :pending, :pending_validations
		alias_method :pendings, :pending_validations
		alias_method :pending_validation, :pending_validations
	end

end

CP = CompletedProc
