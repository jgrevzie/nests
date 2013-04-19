



require 'spreadsheet'

class Object
  def nil_or_strip!
    unless self.nil? 
      self.strip!
      self.squeeze!(' ')
    end
    return self
  end
end
class String
  def lc_alpha; self ? self.downcase.gsub(/[^a-z]/, '') : '' end
end   

module SpreadsheetLoader

  def self.get_dept_name file_name
    raise "#{file_name} is not an excel file" unless File.extname(file_name)=='.xls'
    File.basename file_name, '.xls'
  end

  def self.get_sheet(file_name, sheet_name)
    spready = Spreadsheet.open file_name
    spready.worksheets.find {|w| w.name.downcase==sheet_name.downcase} ||
      raise("Couldn't find sheet '#{sheet_name}'")
  end

  def self.get_headers sheet    
    headers = sheet.first.map &:downcase
    unless headers[0] && headers[0] == "name"
      raise "Couldn't find start of table (looking for 'n/Name' in column A)"
    end
    return headers
  end    

  def self.load_from_spreadsheet file_name, *args
    opts = args.extract_options!
    sheet = get_sheet(file_name, opts[:symbol].to_s.pluralize)

    sheet.each sheet.first.idx+1 do |row|
      next if row[0].nil? # Blank line in middle of table.
      opts[:munger].call( h=HashWithIndifferentAccess[get_headers(sheet).zip row] )
      Fabricate opts[:symbol], h.merge(dept: opts[:dept])
    end
  end

  def self.load_procs file_name, dept
    load_from_spreadsheet file_name, symbol: :procedure, dept: dept, munger: lambda { |h|
      %w(name abbrev comments).map {|i| h[i].nil_or_strip!}
      h[:options].nil_or_strip! && h[:options].gsub!(', ',',')
    }
  end

  def self.load_nurses file_name, dept
    load_from_spreadsheet file_name, symbol: :nurse, dept: dept, munger: lambda { |h|
      fn, ln = h['name'].split[0].lc_alpha, h['name'].split[-1].lc_alpha
      h['username'] = fn + ln[0] unless h['username']
      h['validator'] = h['validator'] ? h['validator'].to_s.downcase.start_with?('y', 't') : false
      h['email'] = "#{fn}.#{ln}@svpm.org.au" unless h['email']
      h['password'] = ln
    }
  end
      
end

SL = SpreadsheetLoader