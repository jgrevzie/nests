




require 'spec_helper'

describe CompletedProcsController do
  def valid_session ; end

  def login(nurse) request.cookies[:nurse_id] = nurse.id end

  def setup_and_POST_valid_proc(nurse)
    login nurse
    # Fabricate comp proc to get a nice set of attrs, but remove _id so we don't always update.
    cp = Fabricate :completed_proc, status: CompletedProc::VALID, nurse: nurse
    post :create, {id: cp.id, completed_proc: cp.attributes.except('_id')}, valid_session
  end    

  after(:each) { expect(response.code).to eq("302") }

  describe "security check for POST" do
     it "doesn't let an ordinary nurse make a new validated proc" do
      setup_and_POST_valid_proc Fabricate :nurse
      # There should be a pending proc, since the controller will ignore {validated: true}
      # unless the nurse is a validator
      CompletedProc.pending.count.should eq 1
    end
    it "allows validating nurse to make a new validated proc" do
      setup_and_POST_valid_proc Fabricate :v_nurse
      # There should be 2 valid procs.
      CompletedProc.pending.count.should eq 0
      CompletedProc.where(status: CP::VALID).count.should eq 2
    end
  end

  describe "security check for PUT" do
    def setup_and_PUT_proc(nurse, *args)
      options = args.extract_options!
      login nurse
      cp = Fabricate :completed_proc, nurse: nurse
      put :update, 
          {id: cp.id, completed_proc: cp.attributes.merge(status: options[:status])}, 
          valid_session
    end
    it "doesn't let an ordinary nurse update an existing proc to status=VALID" do
      setup_and_PUT_proc Fabricate(:nurse), status: CP::VALID
      CompletedProc.pending.count.should eq 1
    end
    it "doesn't let an ordinary nurse update an existing proc to status=REJECTED" do
      setup_and_PUT_proc Fabricate(:nurse), status: CP::REJECTED
      CompletedProc.pending.count.should eq 1
    end
    it "allows validating nurse to validate an existing proc" do
      setup_and_PUT_proc Fabricate(:v_nurse), status: CP::VALID
      CompletedProc.pending.count.should eq 0
      CompletedProc.where(status: CP::VALID).count.should eq 1
    end
   it "allows v nurse to reject an existing proc" do 
      setup_and_PUT_proc Fabricate(:v_nurse), status: CP::REJECTED
      CompletedProc.where(status: CP::REJECTED).count.should eq 1
    end
  end
end
