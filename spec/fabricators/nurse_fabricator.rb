






def random_nurse
	return Nurse.all.sample if Nurse.count>0
	return Fabricate :nurse
end

def v_nurses ; Nurse.where(validator:true) end
def random_v_nurse
	return v_nurses.all.sample if v_nurses.count>0
	return Fabricate :v_nurse
end

Fabricator(:nurse) do
	name {sequence(:name) {|i| "Nancy Jones#{i}"}}
	username {sequence(:uname) {|i| "nancy#{i}" }}
	password 'password'
	dept(fabricator: :dept_singleton)
	email {sequence(:email) {|i| "nancy#{i}@example.com"}}
end

Fabricator(:nurse_random_procs, from: :nurse, aliases: [:nurse_rand_procs, :nurse_rp]) do
	transient :n_procs, :proc_name, :quantity, status: CP::PENDING
	completed_procs {|a| Array.new(a[:n_procs] || 1) {
		Fabricate :rand_cp, opt_params(a, :status, :dept, :proc_name, :quantity)}}
end

Fabricator(:nurse_5p, from: :nurse_rp, aliases: [:nurse_5p, :nurse_5p]) do
	transient :n_procs => 5
end

Fabricator(:nurse_1_pending, from: :nurse_rp, aliases: [:nurse_1p]) do
end

Fabricator :v_nurse, from: :nurse do
	validator true
end
