




require 'csv'
csv = CSV($stdin, :headers => true)
csv.each do |row|
	puts 'Procedure.create(' \
		+ ' :name => "' + row['Name'] + '",' \
		+ ' :abbrev => "' + (row['Abbrev'] || '') + '",'\
		+ ' :options => "' + (row['Options'] || '') + '"' \
		+ ' )'
end

puts 'Nurse.create(:name => "Jackie Peyton")''