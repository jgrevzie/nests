






Fabricator(:nurse) do
	first_name 'nancy'
	username { sequence(:username) { |i| "nancy#{i}" }}
	password 'password'
end

Fabricator(:nurse_5_procs, from: :nurse) do
	after_create {|n| 5.times { n.completed_procs << Fabricate(:random_completed_proc) }}
end

Fabricator(:nurse_5_pending, from: :nurse, aliases: [:nurse_5_pendings]) do
	after_create {|n| 5.times { n.completed_procs << Fabricate(:random_completed_proc, 
																														 status: CompletedProc::PENDING) }}
end

Fabricator(:nurse_1_proc, from: :nurse) do
	transient :proc_name, :q
	after_create do |me, t| 
		params = [] << ( [:proc_name, t[:proc_name]] if t[:proc_name] )
		params << [:quantity, t[:q]] if t[:q]
		me.completed_procs << Fabricate(:completed_proc, Hash[params])
	end
end

Fabricator :v_nurse, from: :nurse do
	validator true
end
