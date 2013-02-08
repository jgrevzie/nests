






Fabricator(:nurse) do
	username 'jackie'
	password 'password'
end

Fabricator(:nurse_5_procs, from: :nurse) do
	after_create { |n| 5.times {n.completed_procs << Fabricate(:completed_proc)} }
end

Fabricator(:nurse_seq, from: :nurse) do
	username { sequence(:username) { |i| "nurse#{i}" }}
	password 'password'
end

Fabricator(:head_nurse_5_subs, from: :nurse) do
	username 'headnurse'
	password 'password'
	validator true
	after_create { |hnurse| 5.times {hnurse.validatees << Fabricate(:nurse_seq)} }
end