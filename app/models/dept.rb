



class Dept
  include Mongoid::Document

  field :name
  field :hospital
  field :location

  has_many :nurses
  has_many :procedures

  validates :name, uniqueness: {scope: [:hospital, :location]}
  def full_name; "#{self.name} (#{self.hospital}, #{self.location})" end
end
