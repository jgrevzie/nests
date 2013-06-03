



def random_existing_proc *args
  # will try to find a proc that matches, else makes up a new proc that matches
  options = args.extract_options!
  return Procedure.where(options).sample if Procedure.where(options).count>0
  return Fabricate :proc, options
end

Fabricator(:proc, from: :procedure, aliases: [:proc_seq, :procedure]) do
	name { sequence { |i| "procedure#{i}" } }
  dept(fabricator: :dept_singleton)
end
