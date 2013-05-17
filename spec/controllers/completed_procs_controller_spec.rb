




require 'spec_helper'

describe CompletedProcsController, reset_db: false do
  before(:all) { load_cathlab_procs }
  before(:each) {@pv_before = pv}
  
  def pv ; CompletedProc.pending.count end
  def valid_session ; end

  def login(nurse) request.cookies[:nurse_id] = nurse.id end

  def setup_and_POST_valid_proc(nurse)
    login nurse
    # Fabricate comp proc to get a nice set of attrs, but remove _id so we don't always update.
    cp = Fabricate :comp_proc_seq, status: CompletedProc::VALID, nurse: nurse
    post :create, {id: cp.id, completed_proc: cp.attributes.except('_id')}, valid_session
  end    

  after(:each) { expect(response.code).to eq("302") }

  describe "security check for POST" do
     it "doesn't let an ordinary nurse make a new validated proc" do
      setup_and_POST_valid_proc Fabricate :nurse
      # There should be an extra pending proc, since the controller will ignore {validated: true}
      # unless the nurse is a validator
      pv.should eq @pv_before+1
    end
    it "allows validating nurse to make a new validated proc" do
      n_valids = CompletedProc.where(status: CP::VALID).count
      setup_and_POST_valid_proc Fabricate :v_nurse
      # There should be 2 valid procs.
      pv.should eq @pv_before
      CompletedProc.where(status: CP::VALID).count.should eq n_valids+2
    end
  end

  describe "security check for PUT" do
    def setup_and_PUT_proc(nurse, *args)
      options = args.extract_options!
      login nurse
      cp = Fabricate :comp_proc_seq, nurse: nurse
      put :update, 
          {id: cp.id, completed_proc: cp.attributes.merge(status: options[:status])}, 
          valid_session
    end
    it "doesn't let an ordinary nurse update an existing proc to status=VALID" do
      setup_and_PUT_proc Fabricate(:nurse), status: CP::VALID
      pv.should eq @pv_before+1
    end
    it "doesn't let an ordinary nurse update an existing proc to status=REJECTED" do
      setup_and_PUT_proc Fabricate(:nurse), status: CP::REJECTED
      pv.should eq @pv_before+1
    end
    it "allows validating nurse to validate an existing proc" do
      n_valids = CompletedProc.where(status: CP::VALID).count
      setup_and_PUT_proc Fabricate(:v_nurse), status: CP::VALID
      pv.should eq @pv_before
      CompletedProc.where(status: CP::VALID).count.should eq n_valids+1
    end
   it "allows v nurse to reject an existing proc" do 
      setup_and_PUT_proc Fabricate(:v_nurse), status: CP::REJECTED
      CompletedProc.where(status: CP::REJECTED).count.should eq 1
    end
  end
end
