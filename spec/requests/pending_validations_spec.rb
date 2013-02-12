




require 'spec_helper'




describe 'Pending validations for nurse screen' do
  it 'displays a table with a row for each pending proc' do
    head_nurse = Fabricate :head_nurse_5_subs
    n_procs_pending_validation = head_nurse.all_validatee_procs_pending_validation.size
    n_procs_pending_validation.should eq 25

    login head_nurse
    page.should have_content 'Pending Validations'
    page.all('table#pendingValidationsTable tr').count.should == n_procs_pending_validation+1
  end
end