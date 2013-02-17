






NURSE_NAMES = ['Anne', 'Barry', 'Cate', 'Derek', 'Edith', 'Fred', 'Gayleen', 'Harry', 
	'Isabell', 'Josef', 'Karen', 'Larry', 'Maude', 'Azeef', 'Ashima', 'Ross', 'Sonna', 'Nancy']

Fabricator(:nurse) do
	first_name { NURSE_NAMES.sample }
	username { sequence(:username) { |i| "userid#{i}" }}
	password 'password'
end

Fabricator(:nurse_5_procs, from: :nurse) do
	after_create { |n| 5.times {n.completed_procs << Fabricate(:random_completed_proc)} }
end

Fabricator(:head_nurse_5_subs, from: :nurse) do
	validator true
	after_create { |hnurse| 5.times {hnurse.validatees << Fabricate(:nurse_5_procs)} }
end

Fabricator(:nurse_1_proc, from: :nurse) do
	transient :proc_name, :q
	after_create do |me, t| 
		params = [] << ( [:proc_name, t[:proc_name]] if t[:proc_name] )
		params << [:quantity, t[:q]] if t[:q]
		me.completed_procs << Fabricate(:completed_proc, Hash[params])
	end
end
