











require 'spec_helper'



describe "'Pending validations for nurse' screen" do
  it 'displays a table with a row for each pending proc, shows # of procs' do
    head_nurse = Fabricate :head_nurse_5_subs

    head_nurse.validatees << Fabricate(:nurse_1_proc, proc_name: 'PROC_NAME', q: 5)
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
  it "validates a subset of total procs" do
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
  it "displays links to completed procs, takes user to edit proc screen" do
    hn = Fabricate :nurse, validator: true
    hn.validatees << Fabricate(:nurse_1_proc, proc_name: 'PROC', q: 5)
    login hn
    click_link('PROC (5)')
    page.should have_content 'procedure'
  end

end