



Fabricator(:dept) do
  name { sequence {|i| "Dept #{i}"} }
  hospital "Hospital"
  location "Location"
end

DEPT_NAME = 'Dept Singleton'
Fabricator(:dept_singleton, class_name: :dept) do
  initialize_with { Dept.find_or_create_by(name: DEPT_NAME) }
end