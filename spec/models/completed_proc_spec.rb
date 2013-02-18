require 'spec_helper'




describe "completed_proc" do

  describe "validations" do
     it "fabricates a valid random completed_proc" do
      completed_proc = Fabricate(:random_completed_proc)
    end
  end

  describe '#pending_validations' do 
    it "gets all non-validated procs" do 
      n = Fabricate :nurse_5_procs
      CompletedProc.pending_validations.count.should eq 5
    end
    it "doesn't get validated procs" do
      n1 = Fabricate :nurse_5_procs
      n2 = Fabricate :nurse_5_procs
      vn = Fabricate :v_nurse
      vn.validate n1.completed_procs
      CompletedProc.pending_validations.count.should eq 5
    end
  end

end