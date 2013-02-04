require 'spec_helper'






def add_completed_procs!(nurse, n)
  1..n.times { nurse.completed_procs << Fabricate(:completed_proc) }
end

describe "Nurse" do
  before (:each) do
    @nurse = Fabricate :nurse
    add_completed_procs! @nurse, 5
  end

  describe 'NurseFabricator' do
    it 'fabricates nurses with different usernames' do
      nurse0 = Fabricate(:nurse_seq)
      nurse1 = Fabricate(:nurse_seq)
      nurse0.username.should_not  eq(nurse1.username)
    end
    it 'fabricates sequences of nurses with completed procs' do
      nurse0 = Fabricate(:nurse_seq)
      nurse0.completed_procs.size.should >0
    end
    it 'fabricates head nurse with validatees' do
  	  head_nurse = Fabricate(:head_nurse)
  	  head_nurse.validator.should == true
    end  
    it 'fabricates adds completed procs to a nurse' do 
      @nurse.completed_procs.size.should == 5
    end
  end

  describe 'ProcsNeedingValidation' do 
    it "gets an enumeration of procedures for a nurse that have't been validated" do 
      @nurse.procs_needing_validation.count.should == 5
    end
  end

  describe 'AllValidateeProcsPendingValidation' do 
    it "gets all procs that a head nurse needs to validate" do 
      head_nurse = Fabricate(:head_nurse)
      head_nurse.validatees << @nurse
      head_nurse.all_validatee_procs_pending_validation.count.should == 5
    end
  end

end