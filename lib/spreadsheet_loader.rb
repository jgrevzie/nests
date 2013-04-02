






require 'spreadsheet'

module SpreadsheetLoader
  def self.nil_or_strip(s) s.nil? ? s : s.strip end

  def self.get_dept_name file_name
    raise "#{file_name} is not an excel file" unless File.extname(file_name)=='.xls'
    File.basename file_name, '.xls'
  end

  def self.load_sheet(file_name, sheet_name)
    spready = Spreadsheet.open file_name
    spready.worksheets.find {|w| w.name.downcase==sheet_name.downcase} ||
      raise("Couldn't find sheet '#{sheet_name}'")
  end

  def self.get_headers sheet    
    headers = sheet.first.map {|i| i.downcase}
    unless headers[0] && headers[0] == "name"
      raise "Couldn't find start of table (looking for 'n/Name' in column A)"
    end
    return headers
  end    

  def self.load_procs file_name
    sheet = load_sheet(file_name, 'procedures')
    headers = get_headers sheet

    sheet.each sheet.first.idx+1 do |row|
      h = HashWithIndifferentAccess[headers.zip row]
      Fabricate :procedure, name: nil_or_strip(h[:name]),
                            abbrev: nil_or_strip(h[:abbrev]),
                            options: (h[:options].nil? ? nil : h[:options].gsub(', ',',').strip),
                            comments: nil_or_strip(h[:comments])
    end
  end

  def self.load_nurses_from_spreadsheet(file_name, dept)
    sheet = load_sheet(file_name, 'nurses')
    headers = get_headers sheet

    sheet.each sheet.first.idx+1 do |row|
      h = HashWithIndifferentAccess[headers.zip row]
      fn, ln = h['name'].split[0].lc_alpha, h['name'].split[-1].lc_alpha
      h['username'] = fn[0] + ln unless h['username']
      h['validator'] = h['validator'] ? h['validator'].downcase.start_with?('y', 't') : false
      h['email'] = "#{fn}.#{ln}@svpm.org.au" unless h['email']
      h['password'] = 'password'
    end
      
    n = Fabricate :nurse, h.merge(dept: dept)
  end
end
