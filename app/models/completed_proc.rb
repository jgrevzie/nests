class CompletedProc
	include Mongoid::Document

	MAX_PROCS_PER_DAY = 20

	field :comments
	field :date_start, type: Date
	field :date_end, type: Date
	field :quantity, type: Integer
	field :options
	field :validated, type: Boolean

	has_one :procedure
	belongs_to :nurse

	validates :quantity, :numericality => {
		:greater_than_or_equal_to => 1,
		:less_than_or_equal_to => MAX_PROCS_PER_DAY
	}
	validates :date_start, :timeliness => {
		:before => Date.today+1,
		:after => Date.today.prev_week
	}
	validates :date_end, :timeliness =>  {
		:before => Date.tomorrow,
		:after => Date.current.prev_week,
		:on_or_after => @date_start,
		:if => :@date_end
	}
	validates :procedure, presence: true

	def proc_name=(proc_name)
		self.procedure = Procedure.where(name: proc_name).first
	end

	def proc_name
		self.procedure.name
	end

end
