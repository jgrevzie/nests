



def random_dept
  return Dept.all.sample if Dept.count>0
  return Fabricate :dept_singleton
end

Fabricator(:dept) do
  name { sequence {|i| "Dept #{i}"} }
  hospital "Hospital"
  location "Location"
end

Fabricator(:dept_singleton, class_name: :dept) do
  initialize_with { Dept.find_or_create_by(
    name: 'Dept Singleton',
    hospital: 'Singleton Hospital',
    location: 'Singleton Location') }
end