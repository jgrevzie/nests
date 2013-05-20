




Fabricator(:procedure, aliases: [:proc]) do
  name 'Blaster'
  dept(fabricator: :dept_singleton)
end

Fabricator(:proc_seq, from: :procedure) do
	name { sequence { |i| "procedure#{i}" } }
end
