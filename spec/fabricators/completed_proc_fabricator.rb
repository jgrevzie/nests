






Fabricator(:completed_proc) do
	transient :proc_name
  date_start { Date.today }
	quantity 1
	procedure do |n| 
    if n[:proc_name]
      Fabricate :procedure, name: n[:proc_name]
    else
      Fabricate :procedure
    end
  end
end

Fabricator(:random_completed_proc, from: :completed_proc) do
  date_start { Date.today-Random.rand(0..6) } 
  quantity { Random.rand(1..10) }
  procedure { Fabricate :random_proc }
end