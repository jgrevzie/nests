



require 'spreadsheet'

class Procedure
  include Mongoid::Document
  field :name
  field :abbrev
  field :options
  field :comments

  has_many :completed_procs
  belongs_to :dept

  validates :name, presence: true, uniqueness: true
  validates :dept, presence: true
end
