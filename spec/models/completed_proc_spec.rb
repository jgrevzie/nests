



require 'spec_helper'

describe CompletedProc do
  describe "fabricators" do
    describe ":random_completed_proc" do
      it "uses random existing validator if status VALID or REJECTED" do
        vn_1, vn_2 = Fabricate(:v_nurse), Fabricate(:v_nurse)
        cp = Fabricate :random_completed_proc, status: CP::VALID
        [vn_1.id, vn_2.id].should include cp.validated_by.id
      end
      it "uses procs that are already in the db" do
        clear_db
        Fabricate(:proc_seq)
        Fabricate(:random_proc)
        Procedure.count.should eq 1
      end
    end
  end

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

  describe "#to_s" do
    it "returns summary with quantity if quantity>1" do
      cp = Fabricate :cp, proc_name: 'Slash', quantity: 2, date: Date.today
      cp.to_s.should eq "Slash (2) #{Date.today}"
    end
    it "returns summary without quantity if quantity==1" do
      cp = Fabricate :cp, proc_name: 'Burn', quantity: 1, date: Date.today
      cp.to_s.should eq "Burn #{Date.today}"
    end
  end

end
