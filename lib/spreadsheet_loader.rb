






require 'spreadsheet'
class Object
  def nil_or_strip!; self.nil? || self.strip! end
end

module SpreadsheetLoader

  def self.get_dept_name file_name
    raise "#{file_name} is not an excel file" unless File.extname(file_name)=='.xls'
    File.basename file_name, '.xls'
  end

  # RENAME THIS TO GET SHEET
  def self.load_sheet(file_name, sheet_name)
    spready = Spreadsheet.open file_name
    spready.worksheets.find {|w| w.name.downcase==sheet_name.downcase} ||
      raise("Couldn't find sheet '#{sheet_name}'")
  end
  def self.get_sheet(file_name, sheet_name) self.load_sheet(file_name, sheet_name) end

  def self.get_headers sheet    
    headers = sheet.first.map {|i| i.downcase}
    unless headers[0] && headers[0] == "name"
      raise "Couldn't find start of table (looking for 'n/Name' in column A)"
    end
    return headers
  end    

  def self.load_worksheet file_name, symbol, hash_munger
    sheet = get_sheet(file_name, symbol.to_s.pluralize)

    sheet.each sheet.first.idx+1 do |row|
      hash_munger.call( h=HashWithIndifferentAccess[get_headers(sheet).zip row] )
      Fabricate symbol, h
    end
  end

  def self.load_procs file_name
    self.load_worksheet file_name, :procedure, lambda { |h|
      %w(name, abbrev, comments).map {|i| h[i].nil_or_strip!}
      h[:options].nil? || ( h[:options].strip! ; h[:options].gsub!(', ',',') )
    }
  end

  def self.load_nurses(file_name, dept)
    sheet = load_sheet(file_name, 'nurses')

    sheet.each sheet.first.idx+1 do |row|
      h = HashWithIndifferentAccess[get_headers(sheet).zip row]
      fn, ln = h['name'].split[0].lc_alpha, h['name'].split[-1].lc_alpha
      h['username'] = fn[0] + ln unless h['username']
      h['validator'] = h['validator'] ? h['validator'].downcase.start_with?('y', 't') : false
      h['email'] = "#{fn}.#{ln}@svpm.org.au" unless h['email']
      h['password'] = 'password'
    end
      
    n = Fabricate :nurse, h.merge(dept: dept)
  end
end
