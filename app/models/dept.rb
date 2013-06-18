



class Dept
  include Mongoid::Document

  field :name
  field :hospital
  field :location
  field :upload_errors, type: Array, default: []

  has_many :nurses, validate: false
  has_many :procedures, validate: false

  validates :name, uniqueness: {scope: [:hospital, :location]}

  def full_name; "#{self.name} (#{self.hospital}, #{self.location})" end
end
