class Procedure
  include Mongoid::Document
  field :name
  field :abbrev
  field :options

  validates :name, presence: true, uniqueness: true

  belongs_to :completed_proc
end
