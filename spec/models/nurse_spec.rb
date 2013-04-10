require 'spec_helper'







describe Nurse do

  describe 'fabricators' do
    it '(:nurse) fabricates nurses with different usernames' do
      nurse0 = Fabricate(:nurse)
      nurse1 = Fabricate(:nurse)
      nurse0.username.should_not  eq(nurse1.username)
    end
    it '(:nurse_5_pendings) fabricates nurse with completed procs' do
      n = Fabricate :nurse_5_pendings
      n.completed_procs.size.should == 5
      CompletedProc.all.count.should == 5
    end
  end

  describe '#procs_I_submitted' do 
    it "gets an enumeration of procedures for a nurse that have't been.vdated" do     
      n = Fabricate :nurse_5_pendings
      n.procs_I_submitted.count.should == 5
    end
    it "won't get procs that belong to another nurse" do
      n1 = Fabricate :nurse_5_pendings
      n2 = Fabricate :nurse_5_pendings
      n2.procs_I_submitted.should_not include n1.procs_I_submitted
    end
  end

  describe '.vdate' do
    it "does pretty much what you'd expect :)" do
      5.times { Fabricate :nurse_5_pendings }
      vn = Fabricate :v_nurse

      comp_procs = CompletedProc.pending_validations
      comp_procs.size.should eq 25
      vn.vdate comp_procs
      CompletedProc.pending_validations.size.should eq 0
    end
    it "throws exception if the nurse is not a validator" do
      n1 = Fabricate :nurse_5_pendings
      n2 = Fabricate :nurse
      expect { n2.vdate(CompletedProc.pending_validations) }.to raise_error
    end
  end
  describe ".vdate_by_id" do
    it "takes a list of comp proc ids and.vdates the heck out of them" do
      n = Fabricate :nurse_5_pendings
      vn = Fabricate :v_nurse

      CompletedProc.pending_validations.count.should eq 5
      cp_ids = n.completed_procs.collect {|i| i._id }
      vn.validate_by_id cp_ids
      CompletedProc.pending_validations.count.should eq 0
    end
    it "throws if nurse is not validator" do
      n = Fabricate :nurse
      expect { n.vdate_by_id( (Fabricate :completed_proc).id ) }.to raise_error
    end
  end
  describe "#completed_procs_summary" do
    it "returns an array of totals of.vdated proc types for a given nurse" do
      n = Fabricate :nurse
      n.completed_procs << Fabricate(:completed_proc, proc_name: 'PROC1', quantity: 5)
      n.completed_procs << Fabricate(:completed_proc, proc_name: 'PROC2', quantity: 7)

      vn = Fabricate :v_nurse
      vn.vdate n.completed_procs

      n.completed_procs_summary['PROC1'].should eq 5
      n.completed_procs_summary['PROC2'].should eq 7
    end
    it "doesn't include procs that haven't been.vdated" do
      n = Fabricate :nurse
      n.completed_procs << Fabricate(:completed_proc, proc_name: 'PROC1', quantity: 5) 

      n.completed_procs_summary['PROC1'].should eq 0
    end
  end
  describe "#completed_procs_total" do
    it "returns total number of completed procs for this nurse" do
      n = Fabricate :nurse_5_pending
      vn = Fabricate :v_nurse
      vn.vdate n.completed_procs

      n.completed_procs_total.should eq n.completed_procs.inject(0) {|accu, cp| accu+cp.quantity}
    end
    it "doesn't include rejected or pending procs" do
      n = Fabricate :nurse_random_procs, n_procs: 5
      total = n.completed_procs.inject(0) do |accu, cp| 
        cp.status==CompletedProc::VALID ? accu+cp.quantity : accu
      end
      n.completed_procs_total.should eq total
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
  # Nurse.send_all_pending_validation_mails
  # tests are in spec for mailer
end #Nurse

