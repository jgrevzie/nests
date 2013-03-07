



class CompletedProc
	include Mongoid::Document

	MAX_PROCS_PER_DAY = 20
	OLDEST_NEW_PROC = Date.today-10

	PENDING = 'pending'
	VALID = 'valid'
	REJECTED = 'rejected'
	INVALID = REJECTED
	ACK_REJECT = 'ack_reject'


	attr_accessor :check_date

	field :comments
	field :date_start, type: Date, default: Date.current
	field :quantity, type: Integer, default: 1
	field :options
	field :status, default: PENDING

	belongs_to :procedure
	belongs_to :nurse

	validates :quantity, numericality: { greater_than_or_equal_to: 1,
																			 less_than_or_equal_to: MAX_PROCS_PER_DAY }
	validates :procedure, presence: { message: "isn't known to CathTraq" }
	validates :status, inclusion: { in: [PENDING, VALID, REJECTED, ACK_REJECT], 
																			 message: 'unknown' }
	validates :date_start, timeliness: { before: Date.today+2, after: OLDEST_NEW_PROC },
												 if: :check_date

	def proc_name=(proc_name)
		self.procedure = Procedure.where(name: proc_name).first
	end

	def proc_name
		self.procedure.name if self.procedure
	end

	def vdate
		self.status = VALID
	end
	def vdated?
		self.status == VALID
	end

	def reject
		self.status = INVALID
	end
	def rejected?
		self.status == REJECTED
	end

	def self.pending_validations
		CompletedProc.where(status: PENDING)
	end

	def ack_reject
		self.status = ACK_REJECT
		self.save
	end

	class << CompletedProc
		alias_method :pending, :pending_validations
		alias_method :pending_validation, :pending_validations
	end

end

CP = CompletedProc
