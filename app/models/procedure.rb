



require 'spreadsheet'

class Procedure
  include Mongoid::Document
  field :name
  field :abbrev
  field :options

  validates :name, presence: true, uniqueness: true

  has_many :completed_procs
  #belongs_to :dept

  def self.nil_or_strip(s) s.nil? ? s : s.strip end
  private_class_method :nil_or_strip

  def self.load_procs_from_spreadsheet file_name
    spready = Spreadsheet.open file_name
    unless sheet = spready.worksheet('Procedures') || spready.worksheet('procedures')
      raise "Couldn't find sheet named 'p/Procedures'"
    end
  
    header = sheet.first.map {|i| i.downcase}
    unless header[0] && header[0] == "name"
      raise "Couldn't find start of procedure table (looking for 'n/Name' in column A)"
    end

    sheet.each sheet.first.idx+1 do |row|
      h = HashWithIndifferentAccess[header.zip row]
      Fabricate :procedure, name: nil_or_strip(h[:name]),
                            abbrev: nil_or_strip(h[:abbrev]),
                            options: (h[:options].nil? ? nil : h[:options].gsub(', ',',').strip)
    end
  end

end
