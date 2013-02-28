




require 'spec_helper'

def valid_session
end

describe CompletedProcsController do
  describe "security checks" do
     it "don't let an ordinary nurse make a validated proc" do
      request.cookies[:nurse_id] = (Fabricate :nurse).id
      cp = Fabricate :completed_proc, status: CompletedProc::VALID
      post :create, {completed_proc: cp.attributes}, valid_session
      # There should be a pending proc, since the controller will ignore {validated: true}
      # unless the nurse is a validator
      CompletedProc.pending.count.should eq 1
    end
    it "don't let an ordinary nurse update a proc to be validated" do
      cp = Fabricate :completed_proc
      put :update, 
          {id: cp.id, completed_proc: cp.attributes.merge(status: CompletedProc::VALID)}, 
          valid_session
      CompletedProc.pending.count.should eq 1
    end
  end
end
