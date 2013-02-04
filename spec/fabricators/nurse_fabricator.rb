






Fabricator(:nurse) do
	username 'jackie'
	password 'password'
end

Fabricator(:nurse_seq, from: :nurse) do
	username { sequence(:username) { |i| "nurse#{i}" }}
	password 'password'
	validator false
	completed_procs(count: 5)
end

Fabricator(:head_nurse, from: :nurse) do
	username 'headnurse'
	password 'password'
	validator true
end