require 'spec_helper'




describe "completed_proc" do

  describe '#pending_validations' do 
    it "gets all non-validated procs" do 
      n = Fabricate :nurse_5_pending
      CompletedProc.pending_validations.count.should eq 5
    end
    it "doesn't get validated procs" do
      n1 = Fabricate :nurse_5_pending
      n2 = Fabricate :nurse_5_pending
      vn = Fabricate :v_nurse
      vn.vdate n1.completed_procs
      CompletedProc.pending_validations.count.should eq 5
    end
  end

  describe "#ack_reject" do
    it "changes status of comp proc to acknowleged" do
      cp = Fabricate :completed_proc
      CompletedProc.pending.count.should eq 1
      cp.ack_reject
      cp.save
      CompletedProc.pending.count.should eq 0
    end
  end

end
