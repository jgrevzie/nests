






class CP
  def after_build!
    # Setup a validator if necessary.
    if [CP::VALID, CP::REJECTED].include? self.status
      vn = Nurse.where(validator: true).to_ary.sample || Fabricate(:v_nurse)
      self.validated_by = vn
    end

    # Setup options if necessary.
    if self.procedure && (opts=self.procedure.options) && opts.size>0
      if opts[-1]=='?' then self.options=[opts.chop, '0'].sample
      else self.options=opts.split(',').sample end
    end
  end
end

Fabricator(:completed_proc, aliases: [:cp]) do
	transient :proc_name
  date_start { Date.today }
	quantity 1
	procedure do |a| 
    params = [] << ( [:name, a[:proc_name]] if a[:proc_name] )
    Fabricate :procedure, Hash[params]
  end
  nurse { Fabricate :nurse }
  after_build {|cp| cp.after_build! }
end

Fabricator(:comp_proc_seq, from: :completed_proc) do
  procedure { Fabricate :proc_seq }
end

Fabricator(:random_completed_proc, from: :completed_proc) do
  date_start { Date.today-Random.rand(1..6) } 
  quantity { Random.rand(5..20) }
  procedure { Fabricate :random_proc}
  status { ([CP::VALID]*15 + [CP::REJECTED] + [CP::PENDING]*3 + [CP::ACK_REJECTED]).sample }
end