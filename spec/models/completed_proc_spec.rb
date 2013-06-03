



require 'spec_helper'

def pv ; CompletedProc.pending_validations.count end

describe CompletedProc do
  describe "fabricators" do
    before(:each) {Nurse.delete_all}
    describe ":random_completed_proc" do
      it "uses random existing validator if status VALID or REJECTED" do
        vn_1, vn_2 = Array.new(2) {Fabricate(:v_nurse)}
        cp = Fabricate :random_completed_proc, status: CP::VALID
        [vn_1.id, vn_2.id].should include cp.validated_by.id
      end
      it "makes new validator if there aren't any in db (and status is VALID or REJECTED)" do
        cp = Fabricate :random_completed_proc, status: CP::REJECTED
        cp.validated_by.id.should_not be_nil
      end
      it "allows dept to be specified" do
        dept = Fabricate :dept, name: 'Toddler Wear'
        procs = Array.new(10) {Fabricate :rand_cp, dept: dept}
        procs.each {|i| i.proc.dept.name.should eq 'Toddler Wear'}
      end
    end
    describe ":completed_proc" do
      it "takes optional parameter proc_name: and sets procedure name" do
        cp = Fabricate :cp, proc_name: 'Shock!'
        cp.proc.name.should eq 'Shock!'
      end
    end
  end

  describe '#pending_validations' do 
    it "gets all non-validated procs" do 
      pv_orig = pv
      n = Fabricate :nurse_5_pending
      pv.should eq pv_orig+5
    end
    it "doesn't get validated procs" do
      pv_orig = pv
      n1 = Fabricate :nurse_5_pending
      n2 = Fabricate :nurse_5_pending
      vn = Fabricate :v_nurse
      vn.vdate n1.completed_procs
      pv.should eq pv_orig+5
    end
  end

  describe "#ack_reject" do
    it "changes status of comp proc to acknowleged" do
      pv_orig = pv
      cp = Fabricate :comp_proc_seq
      pv.should eq pv_orig+1
      cp.ack_reject
      cp.save
      pv.should eq pv_orig
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
