




Fabricator(:procedure, aliases: [:proc]) do
  name 'Blaster'
  dept(fabricator: :dept_singleton)
end

Fabricator(:random_proc, class_name: :procedure) do
	initialize_with { Procedure.all.sample }
end

Fabricator(:proc_seq, from: :procedure) do
	name { sequence { |i| "procedure#{i}" } }
end

