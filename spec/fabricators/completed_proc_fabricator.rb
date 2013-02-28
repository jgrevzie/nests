






Fabricator(:completed_proc) do
	transient :proc_name
  date_start { Date.today }
	quantity 1
	procedure do |a| 
    params = [] << ( [:name, a[:proc_name]] if a[:proc_name] )
    Fabricate :procedure, Hash[params]
  end
end

Fabricator(:comp_proc_seq, from: :completed_proc) do
  procedure { Fabricate :proc_seq }
end

Fabricator(:random_completed_proc, from: :completed_proc) do
  date_start { Date.today-Random.rand(1..6) } 
  quantity { Random.rand(5..20) }
  procedure { Fabricate :random_proc}
  status { ([CompletedProc::VALID]*5 + [CompletedProc::REJECTED, CompletedProc::PENDING]).sample }
end