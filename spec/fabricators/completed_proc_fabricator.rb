




Fabricator(:random_completed_proc, from: :completed_proc) do
	date_start { Date.today-Random.rand(0..6) }	
	quantity { Random.rand(1..10) }
	procedure { Fabricate :random_proc }
end

PROC = Procedure.create(name: 'blah')

Fabricator(:completed_proc) do
	date_start { Date.today }
	quantity 1
	procedure { PROC }
end