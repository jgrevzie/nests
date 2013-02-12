



Fabricator(:random_proc, from: :procedure) do
	initialize_with { Procedure.all.sample }
end

Fabricator(:procedure) do
	name 'Blaster'
end

Fabricator(:proc_seq, from: :procedure) do
	name { sequence(:name) { |i| "procedure#{i}" } }
end