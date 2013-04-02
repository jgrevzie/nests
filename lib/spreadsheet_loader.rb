






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

  def self.load_procs file_name
    sheet = load_sheet(file_name, 'procedures')
    header = sheet.first.map {|i| i.downcase}
    unless header[0] && header[0] == "name"
      raise "Couldn't find start of procedure table (looking for 'n/Name' in column A)"
    end

    sheet.each sheet.first.idx+1 do |row|
      h = HashWithIndifferentAccess[header.zip row]
      Fabricate :procedure, name: nil_or_strip(h[:name]),
                            abbrev: nil_or_strip(h[:abbrev]),
                            options: (h[:options].nil? ? nil : h[:options].gsub(', ',',').strip),
                            comments: nil_or_strip(h[:comments])
    end
  end
  def self.load_nurses_from_spreadsheet(file_name, dept)
    sheet = load_sheet filename, 'nurses'
    dept_name = get_dept_name file_name
    dept1 = Fabricate :dept, name: 'CathLab', hospital: "St V's Private", location: 'Vict'
    dept2 = Fabricate :dept, name: 'Theatre', hospital: "St V's Private", location: 'Vict'

    csv = CSV.foreach(file_name, headers: true) do |row|
      fn, ln = row['name'].split[0].lc_alpha, row['name'].split[-1].lc_alpha
      row['username'] = fn[0] + ln unless row['username']
      row['validator'] = row['validator'] ? row['validator'].downcase.start_with?('y', 't') : false
      row['email'] = "#{fn}.#{ln}@svpm.org.au" unless row['email']
      row['password'] = 'password'
      
      # CSV::Row needs to be converted to hash
      n = Fabricate :nurse, row.to_hash.merge(dept: dept1)
      50.times { n.completed_procs << Fabricate(:random_completed_proc) }
    end
  end
end
