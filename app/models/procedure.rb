



require 'csv'

class Procedure
  include Mongoid::Document
  field :name
  field :abbrev
  field :options

  validates :name, presence: true, uniqueness: true

  has_many :completed_procs



  DB_DIR = ENV['DIR'] || File.join(Rails.root, 'db')

  def self.load_procs_from_spreadsheet(seeds_file)
    csv = CSV.foreach(seeds_file, 
                      headers: true, 
                      converters: lambda {|field| field.nil? ? "" : field}) do |row|
      Fabricate :procedure, name: row['name'].strip,
                            abbrev: row['abbrev'].strip,
                            options: row['options'].gsub(', ',',').strip
    end
  end

end
