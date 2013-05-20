






Fabricator(:nurse) do
	name {sequence {|i| "Nancy Jones#{i}"}}
	username {sequence {|i| "nancy#{i}" }}
	password 'password'
	dept(fabricator: :dept_singleton)
	email {sequence {|i| "nancy#{i}@example.com"}}
end

Fabricator(:nurse_random_procs, from: :nurse) do
	transient :n_procs
	completed_procs { |attrs| Array.new(attrs[:n_procs] || 1) {Fabricate(:random_completed_proc)} } 
end

Fabricator(:nurse_5_pending, from: :nurse, aliases: [:nurse_5_pendings]) do
	completed_procs(count: 5) {Fabricate :random_completed_proc, status: CP::PENDING}
end

# Fabricates a nurse with 1 pending completed proc.
# Client can pass in (quantity: set quantity in completed proc), (proc_name: name of proc in cp) 
Fabricator(:nurse_1_proc, from: :nurse) do
	transient :proc_name, :quantity
	completed_procs(count: 1) {|attrs| 
		Fabricate :completed_proc, opt_params(attrs, :proc_name, :quantity)}
end

Fabricator :v_nurse, from: :nurse do
	validator true
end

