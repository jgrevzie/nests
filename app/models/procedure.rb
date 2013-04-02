



require 'spreadsheet'

class Procedure
  include Mongoid::Document
  field :name
  field :abbrev
  field :options
  field :comments

  validates :name, presence: true, uniqueness: true

  has_many :completed_procs
  #belongs_to :dept
end
