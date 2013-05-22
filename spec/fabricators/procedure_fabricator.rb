



def random_proc
  return Procedure.all.sample if Procedure.count>0
  return Fabricate :proc_seq, dept: random_dept
end

Fabricator(:proc, from: :procedure, aliases: [:proc_seq, :procedure]) do
	name { sequence { |i| "procedure#{i}" } }
  dept(fabricator: :dept_singleton)
end
