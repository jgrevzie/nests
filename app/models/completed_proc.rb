class CompletedProc
	include Mongoid::Document

	MAX_PROCS_PER_DAY = 20

	PENDING = 'blah1'
	VALID = 'blah2'
	INVALID = 'blah5'
	REJECTED = INVALID
	ACK_REJECT = 'blah7'


	field :comments
	field :date_start, type: Date, default: Date.current
	field :quantity, type: Integer, default: 1
	field :options
	field :status, default: PENDING

	belongs_to :procedure
	belongs_to :nurse

	validates :quantity, numericality: { greater_than_or_equal_to: 1,
																			 less_than_or_equal_to: MAX_PROCS_PER_DAY }
	validates :date_start, timeliness: { before: Date.today+2, after: Date.today.prev_week }
	validates :procedure, presence: { message: "isn't known to CathTraq" }
	validates :status, inclusion: { in: [PENDING, VALID, INVALID, ACK_REJECT], message: 'unknown' }

	def proc_name=(proc_name)
		self.procedure = Procedure.where(name: proc_name).first
	end

	def proc_name
		self.procedure.name if self.procedure
	end

	def validate
		self.status = VALID
	end
	def validated?
		self.status == VALID
	end
	def reject
		self.status = INVALID
	end

	def self.pending_validations
		CompletedProc.where(status: PENDING)
	end

	def acknowledge_reject
		self.status = ACK_REJECT
		self.save
	end

	class << CompletedProc
		alias_method :pending, :pending_validations
		alias_method :pending_validation, :pending_validations
	end

end
