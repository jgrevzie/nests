class Procedure
  include Mongoid::Document
  field :name
  field :abbrev
  field :options

  validates :name, presence: true, uniqueness: true

  has_many :completed_procs
end
