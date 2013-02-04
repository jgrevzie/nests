



Fabricator(:random_proc, from: :procedure) do
	initialize_with { Procedure.all.sample }
end

Fabricator(:procedure) do
	name 'blah'
end