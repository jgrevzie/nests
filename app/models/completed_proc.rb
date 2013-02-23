class CompletedProc
	include Mongoid::Document

	MAX_PROCS_PER_DAY = 20

	field :comments
	field :date_start, type: Date, default: Date.current
	field :quantity, type: Integer, default: 1
	field :options
	field :validated, type: Boolean, default: false

	belongs_to :procedure
	belongs_to :nurse

	validates :quantity, :numericality => {
		:greater_than_or_equal_to => 1,
		:less_than_or_equal_to => MAX_PROCS_PER_DAY
	}
	validates :date_start, :timeliness => {
		:before => Date.today+2,
		:after => Date.today.prev_week
	}
	validates :procedure, presence: true

	def proc_name=(proc_name)
		self.procedure = Procedure.where(name: proc_name).first
	end

	def proc_name
		self.procedure.name if self.procedure
	end

	def self.pending_validations
		CompletedProc.where(validated: false)
	end

	class << CompletedProc
		alias_method :pending, :pending_validations
		alias_method :pending_validation, :pending_validations
	end

end
