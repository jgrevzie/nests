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

  describe '#procs_needing_validation' do 
    it "gets an enumeration of procedures for a nurse that have't been validated" do     
      n = Fabricate :nurse_5_procs
      n.procs_needing_validation.count.should == 5
    end
  end

  describe '#all_validatee_procs_pending_validation' do 
    it "gets all procs that a head nurse needs to validate" do 
      head_nurse = Fabricate :nurse, username: 'head_nurse'
      head_nurse.validatees << Fabricate(:nurse_5_procs)
      head_nurse.all_validatee_procs_pending_validation.count.should == 5
    end
  end

  describe '#validate_procs' do
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

  describe '#can_validate_proc?' do
    it "returns false if this nurse is not a validator" do
      hn = Fabricate :head_nurse_5_subs, validator: false
      hn.can_validate_proc?(hn.validatees[0].completed_procs[0]).should be_false
    end
    it "returns false if supplied proc belongs to Nurse X, but Nurse X doesn't belong to self" do
      hn = Fabricate :head_nurse_5_subs
      n = Fabricate :nurse_1_proc
      hn.can_validate_proc?(n.completed_procs[0]).should be_false
    end
    it "returns false if completed proc doesn't belong to a nurse" do
      hn = Fabricate :head_nurse_5_subs
      cp = Fabricate :completed_proc
      hn.can_validate_proc?(cp).should be_false
    end
    it "returns true if nurse is 'owner' of Nurse X, and proc belongs to Nurse X" do
      hn = Fabricate :nurse, validator: true
      n = Fabricate :nurse_1_proc
      hn.validatees << n
      hn.can_validate_proc?(n.completed_procs[0]).should be_true
    end
  end
end

