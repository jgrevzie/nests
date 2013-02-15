






NURSE_NAMES = ['Anne', 'Barry', 'Cate', 'Derek', 'Edith', 'Fred', 'Gayleen', 'Harry', 
	'Isabell', 'Josef', 'Karen', 'Larry', 'Maude', 'Azeef', 'Ashima', 'Ross', 'Sonna']

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
