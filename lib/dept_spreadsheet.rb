



require 'spreadsheet'

class Object
  def nil_or_strip!
    unless nil? 
      strip!
      squeeze!(' ')
    end
    return self
  end
end

class String
  def lc_alpha; self ? downcase.gsub(/[^a-z]/, '') : '' end
end   

class DeptSpreadsheet
  def initialize(io) @io = io end

  def get_sheet *sheet_names
    spready = Spreadsheet.open @io
    spready.worksheets.find {|w| sheet_names.map(&:downcase).include? w.name.downcase} or
      puts "Couldn't find any of sheet names '#{sheet_names}' in #{@io}"
  end

  def get_headers sheet    
    headers = sheet.first.map &:downcase
    raise "Couldn't find 'n/Name' at top of a column" unless headers.include? "name"
    return headers
  end    

  def load_from_spreadsheet *args
    opts = args.extract_options!
    return unless sheet = get_sheet(opts[:class].to_s.pluralize)

    sheet.each sheet.first.idx+1 do |row|
         next unless row.any? {|i| !i.nil? } # Blank line in middle of table.
      opts[:munger].call( h=HashWithIndifferentAccess[get_headers(sheet).zip row] )
      opts[:class].create! h.merge(dept: @dept)
    end
  end

  def load_procs
    load_from_spreadsheet class: Procedure, munger: lambda { |h|
      %w(name abbrev comments).map {|i| h[i].nil_or_strip!}
      h[:options].nil_or_strip! && h[:options].gsub!(', ',',')
    }
  end

  def load_nurses
    load_from_spreadsheet class: Nurse, dept: @dept, munger: lambda { |h|
      fn, ln = h[:name].split[0].lc_alpha, h[:name].split[-1].lc_alpha
      h[:username] = fn + ln[0] unless h[:username]
      h[:validator] = h[:validator] ? h[:validator].to_s.downcase.start_with?('y', 't') : false
      # following could be replaced with an eval of an attr of dept
      h[:email] = "#{fn}.#{ln}@svpm.org.au" unless h[:email]
      h[:password] = ln
    }
  end

  def key_value_pairs sheet
    hash = HashWithIndifferentAccess.new
    sheet.each sheet.first.idx do |row| hash[ row[0] ] = row[1] if row[0] end
    return hash
  end

  def get_dept_info_sheet
    get_sheet 'dept', 'dept info', 'department', 'department info'
  end

  def load_dept_info
    raise("Couldn't get department info, aborting.") unless dept_sheet = get_dept_info_sheet
    @dept = Dept.create key_value_pairs(dept_sheet)
  end

  def self.load_dept io
    ds = DS.new io
    (ds.load_procs ; ds.load_nurses) if (dept=ds.load_dept_info).valid?
    return dept
  end
      
end

DS = DeptSpreadsheet