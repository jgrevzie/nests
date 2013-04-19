



class CompletedProc
  def after_build!
    # Setup a validator if necessary.
    if [CP::VALID, CP::REJECTED].include? self.status
      vn = Nurse.where(validator: true).to_ary.sample || Fabricate(:v_nurse)
      self.validated_by = vn
    end

    # Setup options if necessary.
    if self.proc && (opts=self.proc.options) && opts.size>0
      if opts[-1]=='?' then self.options=[opts.chop, '0'].sample
      else self.options=opts.split(',').sample end
    end
  end
end

Fabricator(:completed_proc, aliases: [:cp]) do
	transient :proc_name
  date { Date.today }
	quantity 1
	# Check if proc_name: was specified, other build defulat procedure.
  proc do |a| 
    params = [] << ( [:name, a[:proc_name]] if a[:proc_name] )
    Fabricate :procedure, Hash[params]
  end
  #nurse { Fabricate :nurse }
  role CP::SCRUBBED
  after_build {|cp| cp.after_build! }
end

Fabricator(:comp_proc_seq, from: :completed_proc) do
  proc { Fabricate :proc_seq }
end

Fabricator(:random_completed_proc, from: :completed_proc, aliases: [:rand_cp]) do
  date { Date.today-Random.rand(1..6) } 
  quantity { Random.rand(5..20) }
  proc { Fabricate :random_proc}
  status { ([CP::VALID]*15 + [CP::REJECTED] + [CP::PENDING]*3 + [CP::ACK_REJECTED]).sample }
  role {CP::ROLES.sample}
  emergency {[true, false].sample}
end