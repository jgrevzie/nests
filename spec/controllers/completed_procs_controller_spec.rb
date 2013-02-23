




require 'spec_helper'

def valid_session
  n = Fabricate :nurse
  { nurse_id: n.id }
end

describe CompletedProcsController do
  describe "security checks" do
     it "don't let an ordinary nurse make a validated proc" do
      cp = Fabricate :completed_proc, status: 'valid'
      post :create, {completed_proc: cp.attributes}, valid_session
      # There should be a pending proc, since the controller will ignore validated: true
      # unless the nurse is a validator
      CompletedProc.pending.count.should eq 1
    end
    it "don't let an ordinary nurse update a proc to be validated" do
      cp = Fabricate :completed_proc
      put :update, {id: cp.id, completed_proc: cp.attributes.merge(status: 'valid')}, valid_session
      CompletedProc.pending.count.should eq 1
    end
  end
end
