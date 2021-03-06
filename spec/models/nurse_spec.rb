



require 'spec_helper'

describe Nurse do

  describe 'fabricators' do
    it '(:nurse) fabricates nurses with different usernames' do
      nurse0 = Fabricate(:nurse)
      nurse1 = Fabricate(:nurse)
      nurse0.username.should_not  eq(nurse1.username)
    end
    it '(:nurse_5p) fabricates nurse with completed procs' do
      n_comp_procs = CompletedProc.all.count
      n = Fabricate :nurse_5p
      n.completed_procs.size.should == 5
      CompletedProc.all.count.should == n_comp_procs+5
    end
    it '(:nurse_1p) allows optional params proc_name: and quantity:, specify dept' do
      clear_db
      d = Fabricate :dept, name:'Robot Lubricants'
      n = Fabricate :nurse_1p, proc_name: 'Robot Dance', quantity: 5, dept: d
      n.dept.should eq d
      (cp=n.completed_procs[0]).proc.name.should eq 'Robot Dance'
      cp.quantity.should eq 5
      cp.proc.dept.should eq d
      cp.status.should eq CP::PENDING
    end
    it '(:nurse_random_procs) allows optional param :n_procs to specify number of procs' do
      (Fabricate :nurse_random_procs, n_procs: 2).completed_procs.size.should eq 2
    end
    it '(:nurse_random_procs) defaults to a single proc' do
      (Fabricate :nurse_random_procs).completed_procs.size.should eq 1
    end
    it '(:nurse_random_procs) allows :dept to specify dept, sets dept of nurse and procs' do 
      dept = Fabricate :dept, name: 'Knitwear'
      n = Fabricate :nurse_random_procs, dept: dept
      n.dept.should eq dept
      n.completed_procs[0].proc.dept.should eq dept
    end
  end

  describe '#pendings' do 
    it "gets an enumeration of procedures for a nurse that have't been.vdated" do     
      n = Fabricate :nurse_1p
      n.pendings.count.should == 1
    end
    it "won't get procs that belong to another nurse" do
      n1 = Fabricate :nurse_1p
      n2 = Fabricate :nurse_1p
      n2.pendings.should_not include n1.pendings
    end
  end

  describe '#vdate' do
    it "does pretty much what you'd expect :)" do
      n_pendings = CompletedProc.pending_validations.size
      2.times { Fabricate :nurse_1p }
      vn = Fabricate :v_nurse

      comp_procs = CompletedProc.pending_validations
      comp_procs.size.should eq n_pendings+2
      vn.vdate comp_procs
      CompletedProc.pending_validations.size.should eq 0
    end
    it "throws exception if the nurse is not a validator" do
      n1 = Fabricate :nurse_1p
      n2 = Fabricate :nurse
      expect { n2.vdate(CompletedProc.pending_validations) }.to raise_error
    end
  end
  describe "#vdate_by_id" do
    it "takes a list of comp proc ids and.vdates the heck out of them" do
      n_pending = CompletedProc.pending_validations.count

      n = Fabricate :nurse_5p
      vn = Fabricate :v_nurse

      CompletedProc.pending_validations.count.should eq n_pending+5
      cp_ids = n.completed_procs.collect &:_id
      vn.validate_by_id cp_ids
      CompletedProc.pending_validations.count.should eq n_pending
    end
    it "throws if nurse is not validator" do
      n = Fabricate :nurse
      expect { n.vdate_by_id( (Fabricate :completed_proc).id ) }.to raise_error
    end
  end
  describe "#completed_procs_summary" do
    it "returns an array of totals of proc types a given nurse has completed" do
      n = Fabricate :nurse
      p1 = Fabricate :proc
      p2 = Fabricate :proc
      n.completed_procs << (cp_1=Fabricate(:cp, quantity: 5, proc: p1))
      n.completed_procs << (cp_2=Fabricate(:cp, quantity: 7, proc: p2))

      vn = Fabricate :v_nurse
      vn.vdate n.completed_procs

      n.completed_procs_summary[cp_1.proc.name].should eq 5
      n.completed_procs_summary[cp_2.proc.name].should eq 7
    end
    it "doesn't include procs that haven't been.vdated" do
      n = Fabricate :nurse
      n.completed_procs << (cp=Fabricate(:comp_proc_seq, quantity: 5))

      n.completed_procs_summary[cp.proc.name].should be_nil
    end
    it "doesn't return procs with zero quantity" do
      (n = Fabricate :nurse).completed_procs << Fabricate(:comp_proc_seq, quantity: 7)
      (Fabricate :v_nurse).vdate n.completed_procs
      stray_proc = Fabricate :proc_seq
      n.completed_procs_summary[stray_proc.name].should be_nil
    end
  end
  describe "#completed_procs_total" do
    it "returns total number of completed procs for this nurse" do
      n = Fabricate :nurse_5p
      vn = Fabricate :v_nurse
      vn.vdate n.completed_procs

      n.completed_procs_total.should eq n.completed_procs.inject(0) {|accu, cp| accu+cp.
        quantity}
    end
    it "doesn't include rejected or pending procs" do
      n = Fabricate :nurse_random_procs, n_procs: 5
      total = n.completed_procs.inject(0) do |accu, cp| 
        cp.status==CompletedProc::VALID ? accu+cp.quantity : accu
      end
      n.completed_procs_total.should eq total
    end
    it "no procs gives count of zero" do
      n = Fabricate :nurse
      n.completed_procs_total.should eq 0
    end
  end
  describe "filters" do
    before(:each) do
      clear_db
      @n = Fabricate :nurse
      @n.completed_procs << Fabricate(:cp, proc_name: 'PROC1', quantity: 5)
      @n.completed_procs << Fabricate(:cp, proc_name: 'PROC2', quantity: 7, emergency: true)
      
      vn = Fabricate :v_nurse
      vn.vdate @n.completed_procs
    end
    it "#completed_procs_summary"  do
      @n.completed_procs_summary(emergency: true)['PROC1'].should be_nil
      @n.completed_procs_summary(emergency: true)['PROC2'].should eq 7
    end
    it "#completed_procs_total" do
      @n.completed_procs_total(emergency: true).should eq 7
    end

  end
  describe "#first_name" do
    it "gets first name of nurse (weird right?)" do
      n = Fabricate :nurse, name: 'Pewee Herman'
      n.first_name.should eq 'Pewee'
    end
    it "handles long names with grace" do
      n = Fabricate :nurse, name: 'Josef Abernet Capitulo Mazzenia'
      n.first_name.should eq 'Josef'
    end
  end
  describe "#last_name" do
    it "gets last name of nurse, doesn't try to rub your face in it" do
      n = Fabricate :nurse, name: 'Great Scott'
      n.last_name.should eq 'Scott'
    end
    it "doesn't care about silly names, that are epic in magnitude" do
      n = Fabricate :nurse, name: "James Fredrick Mulberry Fortesque D'Angelo"
      n.last_name.should eq "D'Angelo"
    end
  end
  describe "#procs_i_can_validate" do
    before(:all) do
      @dept = Fabricate :dept, name: 'kitchenware'
      @vn = Fabricate :v_nurse, dept: @dept
      Fabricate :nurse_rand_procs, status: CP::PENDING, dept: @dept, n_procs: 5
    end

    it "returns a list of procs that the nurse can validate" do
      @vn.procs_i_can_validate.count.should eq 5
    end
    it "only provides procs in same dept as v nurse" do
      Fabricate :dept, name: 'Manchester'
      @vn.procs_i_can_validate.count.should eq 5
    end
  end
  # Nurse.send_all_pending_validation_mails
  # tests are in spec for mailer
end #Nurse

