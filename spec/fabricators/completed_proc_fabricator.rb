



Fabricator(:completed_proc, aliases: [:cp, :comp_proc_seq, :cp_seq]) do
	transient :proc_name, :dept
  date { Date.today }
	quantity 1
	# If proc_name: was specified, use that as proc name.
  proc {|attrs| Fabricate :proc_seq, opt_params(attrs, :dept, proc_name: :name)}
  role CP::SCRUBBED
  nurse {random_nurse}
  
  after_build do |cp|
    # Setup a validator if necessary.
    if [CP::VALID, CP::REJECTED].include? cp.status
      vn = Nurse.where(validator: true).to_ary.sample || random_v_nurse
      cp.validated_by = vn
    end

    # Setup options if necessary.
    if cp.proc && (opts=cp.proc.options) && opts.size>0
      if opts[-1]=='?' then cp.options=[opts.chop, '0'].sample
      else cp.options=opts.split(',').sample end
    end
  end
end

Fabricator(:random_completed_proc, from: :completed_proc, aliases: [:rand_cp]) do
  date { Date.today-Random.rand(1..6) } 
  quantity { Random.rand(5..20) }
  proc {random_proc}
  status { ([CP::VALID]*15 + [CP::REJECTED] + [CP::PENDING]*3 + [CP::ACK_REJECTED]).sample }
  role {CP::ROLES.sample}
  emergency {[true, false].sample}
end

