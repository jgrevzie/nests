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
  end

  describe '#procs_I_submitted' do 
    it "gets an enumeration of procedures for a nurse that have't been validated" do     
      n = Fabricate :nurse_5_procs
      n.procs_I_submitted.count.should == 5
    end
    it "won't get procs that belong to another nurse" do
      n1 = Fabricate :nurse_5_procs
      n2 = Fabricate :nurse_5_procs
      n2.procs_I_submitted.should_not include n1.procs_I_submitted
    end
  end

  describe '#validate' do
    it "does pretty much what you'd expect :)" do
      5.times { Fabricate :nurse_5_procs }
      vn = Fabricate :v_nurse

      comp_procs = CompletedProc.pending_validations
      comp_procs.size.should eq 25
      vn.validate comp_procs
      CompletedProc.pending_validations.size.should eq 0
    end
    it "throws exception if the nurse is not a validator" do
      n1 = Fabricate :nurse_5_procs
      n2 = Fabricate :nurse
      expect { n2.validate(CompletedProc.pending_validations) }.to raise_error
    end
  end
  describe "#validate_by_id" do
    it "takes a list of comp proc ids and validates the heck out of them" do
      n = Fabricate :nurse_5_procs
      vn = Fabricate :v_nurse

      CompletedProc.pending_validations.count.should eq 5
      cp_ids = n.completed_procs.collect {|i| i._id }
      vn.validate_by_id cp_ids
      CompletedProc.pending_validations.count.should eq 0
    end
    it "throws if nurse is not validator" do
      n = Fabricate :nurse
      expect { n.validate_by_id( (Fabricate :completed_proc).id ) }.to raise_error
    end
  end
  describe "#completed_procs_summary" do
    it "returns an array of totals of validated proc types for a given nurse" do
      n = Fabricate :nurse
      n.completed_procs << Fabricate(:completed_proc, proc_name: 'PROC1', quantity: 5)
      n.completed_procs << Fabricate(:completed_proc, proc_name: 'PROC2', quantity: 7)

      vn = Fabricate :v_nurse
      vn.validate n.completed_procs

      n.completed_procs_summary['PROC1'].should eq 5
      n.completed_procs_summary['PROC2'].should eq 7
    end
    it "doesn't include procs that haven't been validated" do
      n = Fabricate :nurse
      n.completed_procs << Fabricate(:completed_proc, proc_name: 'PROC1', quantity: 5) 

      n.completed_procs_summary['PROC1'].should eq 0
    end
  end

end #Nurse

