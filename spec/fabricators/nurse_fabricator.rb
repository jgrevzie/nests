






Fabricator(:nurse) do
	name {sequence {|i| "Nancy Jones#{i}"}}
	username {sequence {|i| "nancy#{i}" }}
	password 'password'
	dept(fabricator: :dept_singleton)
	email {sequence {|i| "nancy#{i}@example.com"}}
end

Fabricator(:nurse_random_procs, from: :nurse, aliases: [:nurse_rand_procs]) do
	transient :n_procs, status: CP::PENDING
	completed_procs {|attrs| Array.new(attrs[:n_procs] || 1) {
		Fabricate :cp_seq, opt_params(attrs, :status).merge(dept: attrs[:dept])}}
end

Fabricator(:nurse_5_pending, from: :nurse, aliases: [:nurse_5_pendings]) do
	completed_procs(count: 5) {|attrs|
		Fabricate :cp_seq, status: CP::PENDING}
end

# Fabricates a nurse with 1 pending completed proc.
# Client can pass in (quantity: set quantity in completed proc), (proc_name: name of proc in cp) 
Fabricator(:nurse_1_proc, from: :nurse) do
	transient :proc_name, :quantity
	completed_procs(count: 1) {|a| Fabricate :completed_proc, opt_params(a, :proc_name, :quantity)}
end

Fabricator :v_nurse, from: :nurse do
	validator true
end

