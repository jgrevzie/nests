



Fabricator(:dept) do
  name     "CathLab"
  hospital "St Vincent's Private"
  location "Fitzroy, Victoria"
end




class Doggy
  include Mongoid::Document
  field :name
  belongs_to :home
  validates :home, presence: true
end

class Home
  include Mongoid::Document
  field :address
  has_many :doggies
end

Fabricator(:doggy) do
  name 'Jackie'
end
Fabricator(:home) do
  address 'Fitzroy'
end