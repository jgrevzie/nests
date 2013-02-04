require 'spec_helper'






def add_completed_procs!(nurse, n)
  1..n.times { nurse.completed_procs << Fabricate(:random_completed_proc) }
end

describe 'NurseFabricator' do
  it 'fabricates nurses with different usernames' do
  	nurse0 = Fabricate(:nurse_seq)
  	nurse1 = Fabricate(:nurse_seq)
  	nurse0.username.should_not  eq(nurse1.username)
  end
  it 'fabricates nurses with completed procs' do
    nurse0 = Fabricate(:nurse_seq)
    nurse0.completed_procs.count.should >0
  end
  it 'fabricates head nurse with validatees' do
  	head_nurse = Fabricate(:head_nurse)
  	head_nurse.validator.should == true
  	head_nurse.validatees.size > 0
  end  
  it 'fabricates nurse with completed procs' do 
    nurse = Fabricate :nurse
    add_completed_procs!(nurse, 5)
  end
end
