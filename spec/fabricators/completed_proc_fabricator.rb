






Fabricator(:completed_proc, aliases: [:cp]) do
	transient :proc_name
  date_start { Date.today }
	quantity 1
	procedure do |a| 
    params = [] << ( [:name, a[:proc_name]] if a[:proc_name] )
    Fabricate :procedure, Hash[params]
  end
  nurse { Fabricate :nurse }
end

Fabricator(:comp_proc_seq, from: :completed_proc) do
  procedure { Fabricate :proc_seq }
end

def get_random_validator
  if (validators = Nurse.where(validator: true)).count
    validators.to_ary.sample
  else
    Fabricate :v_nurse
  end
end

Fabricator(:random_completed_proc, from: :completed_proc) do
  date_start { Date.today-Random.rand(1..6) } 
  quantity { Random.rand(5..20) }
  procedure { Fabricate :random_proc}
  status { ([CP::VALID]*15 + [CP::REJECTED] + [CP::PENDING]*3 + [CP::ACK_REJECTED]).sample }
  validated_by {|a| get_random_validator if [CP::VALID, CP::REJECTED].include? a[:status]}
end