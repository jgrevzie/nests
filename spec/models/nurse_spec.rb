require 'spec_helper'







describe "Nurse" do

  describe 'fabricators' do
      it '(:nurse) fabricates nurses with different usernames' do
      nurse0 = Fabricate(:nurse)
      nurse1 = Fabricate(:nurse)
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

  describe 'method procs_needing_validation' do 
    it "gets an enumeration of procedures for a nurse that have't been validated" do     
      n = Fabricate :nurse_5_procs
      n.procs_needing_validation.count.should == 5
    end
  end

  describe 'method all_validatee_procs_pending_validation' do 
    it "gets all procs that a head nurse needs to validate" do 
      head_nurse = Fabricate :nurse, username: 'head_nurse'
      head_nurse.validatees << Fabricate(:nurse_5_procs)
      head_nurse.all_validatee_procs_pending_validation.count.should == 5
    end
  end

  describe 'method validate_procs' do
    it "validates completed procedures supplied by id" do
      hn = Fabricate :head_nurse_5_subs
      proc_ids = hn.all_validatee_procs_pending_validation
      proc_ids.size.should eq 25
      hn.validate_procs proc_ids
      hn.all_validatee_procs_pending_validation.size.should eq 0
    end
    it "doesn't validate procs that were submitted by nurses that don't 'belong' to this nurse" do
      hn = Fabricate :head_nurse_5_subs
      n = Fabricate :nurse
      cp = Fabricate :completed_proc
      n.completed_procs << cp
 
      proc_ids = hn.all_validatee_procs_pending_validation << cp._id
      proc_ids.size.should eq 26
      
      hn.validate_procs proc_ids
      cp.validated?.should be false
    end
  end

end
