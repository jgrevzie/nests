



class Dept
  include Mongoid::Document

  field :name
  field :hospital
  field :location
  field :upload_errors, type: Array, default: []

  has_many :nurses, validate: false
  has_many :procedures, validate: false

  attr_accessor :using_upload

  validates :name, uniqueness: {scope: [:hospital, :location]}
  validates_presence_of :name, :hospital, :location

  after_validation {|d| d.errors[:base] << 
    "Does spreadsheet have a 'dept info' worksheet?" if 
      d.using_upload && d.errors.full_messages.grep(/blank/).any?}

  def full_name; "#{self.name} (#{self.hospital}, #{self.location})" end
end
