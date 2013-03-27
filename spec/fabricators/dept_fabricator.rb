



Fabricator(:dept) do
  name { sequence {|i| "Dept #{i}"} }
  hospital "Hospital"
  location "Location"
end
