require 'spec_helper'







describe "Nurse" do

  describe 'nurse fabricators' do
      it '(:nurse_seq) fabricates nurses with different usernames' do
      nurse0 = Fabricate(:nurse_seq)
      nurse1 = Fabricate(:nurse_seq)
      nurse0.username.should_not  eq(nurse1.username)
    end
    it '(:nurse_5_procs) fabricates nurse with completed procs' do
      n = Fabricate :nurse_5_procs
      n.completed_procs.size.should == 5
      CompletedProc.all.count.should == 5
    end
    it '(:head_nurse_5_subs) fabricates head nurse with validatees' do
  	  hn = Fabricate(:head_nurse_5_subs)
  	  hn.validator.should == true
      hn.validatees.size.should == 5
      Nurse.all.count.should == 6
    end  
  end

  describe 'procs_needing_validation' do 
    it "gets an enumeration of procedures for a nurse that have't been validated" do     
      n = Fabricate :nurse_5_procs
      n.procs_needing_validation.count.should == 5
    end
  end

  describe 'all_validatee_procs_pending_validation' do 
    it "gets all procs that a head nurse needs to validate" do 
      head_nurse = Fabricate :nurse, username: 'head_nurse'
      head_nurse.validatees << Fabricate(:nurse_5_procs)
      head_nurse.all_validatee_procs_pending_validation.count.should == 5
    end
  end

end