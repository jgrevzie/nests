



Fabricator(:random_proc, from: :procedure) do
	initialize_with { p = Procedure.all.sample ; puts p.name ; puts p.dept.name ; p}
end

Fabricator(:procedure, aliases: [:proc]) do
	name 'Blaster'
  dept Dept.create name: 'laser'
end

Fabricator(:proc_seq, from: :procedure) do
	name { sequence { |i| "procedure#{i}" } }
end

