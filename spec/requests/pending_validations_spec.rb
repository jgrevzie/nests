











require 'spec_helper'




describe "'Pending validations for nurse' screen" do
  it 'displays a table with a row for each pending proc, shows # of procs' do
    head_nurse = Fabricate :head_nurse_5_subs

    #builds a nurse with a known proc name and quantity
    proc = Fabricate :procedure, name: 'PROC_NAME'
    cp = Fabricate :completed_proc, quantity: 5, procedure: proc
    sub_nurse = Fabricate :nurse
    sub_nurse.completed_procs << cp

    head_nurse.validatees << sub_nurse
    n_procs_pending_validation = head_nurse.all_validatee_procs_pending_validation.size

    login head_nurse
    page.should have_content ApplicationHelper::VALIDATION_CONTENT
    page.all('table#pendingValidationsTable tr').count.should eq n_procs_pending_validation+1
    page.should have_content "PROC_NAME (5)"
  end
  it "validates all procs if submit button is clicked" do
    hn = Fabricate :head_nurse_5_subs
    login hn
    page.should have_content ApplicationHelper::VALIDATION_CONTENT
    click_button 'Validate Checked'
    hn.all_validatee_procs_pending_validation.size.should eq 0
  end
  it "shouldn't give an error screen if there's nothing to validate" do
    login Fabricate :nurse, validator: true
    page.should have_content ApplicationHelper::VALIDATION_CONTENT
    click_button 'Validate Checked'
  end
  it "should be able to validate a few procs" do
    hn = Fabricate :head_nurse_5_subs
    orig_pending = hn.all_validatee_procs_pending_validation.size

    login hn
    page.should have_content ApplicationHelper::VALIDATION_CONTENT

    hn.all_validatee_procs_pending_validation[1..orig_pending/2].each do |proc|
      uncheck "proc_ids[#{proc._id}]"
    end
     
    click_button 'Validate Checked'
    hn.all_validatee_procs_pending_validation.size.should eq orig_pending/2 
  end

end