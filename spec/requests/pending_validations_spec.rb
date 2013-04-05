require 'spec_helper'



describe "'Pending validations for nurse' screen" do
  it 'displays a table with a row for each pending proc, shows # of procs' do
    vn = Fabricate :v_nurse

    Fabricate(:nurse_1_proc, proc_name: 'PROC_NAME', q: 5)
    n_procs_pending_validation = CompletedProc.pending_validations.size

    login vn
    on_pending_vn_page?.should be_true
    page.all('table#pendingValidationsTable tr').count.should eq n_procs_pending_validation+1
    page.should have_content "PROC_NAME (5)"
  end
  it "validates all procs if submit button is clicked" do
    vn = Fabricate :v_nurse
    Fabricate :nurse_5_pendings
    
    CompletedProc.pending_validations.count.should eq 5
    login vn
    on_pending_vn_page?.should be_true
    click_button 'Validate Checked'
    CompletedProc.pending_validations.count.should eq 0
  end
  it "shouldn't give an error screen if there's nothing to validate" do
    login Fabricate :v_nurse
    on_pending_vn_page?.should be_true
    click_button 'Validate Checked'
  end
  it "validates a subset of total procs" do
    vn = Fabricate :v_nurse
    5.times { Fabricate :nurse_5_pendings }

    orig_pending = CompletedProc.pending_validations.count

    login vn
    on_pending_vn_page?.should be_true

    CompletedProc.pending_validations[1..orig_pending/2].each do |proc|
      uncheck "proc_ids[#{proc._id}]"
    end
     
    click_button 'Validate Checked'
    CompletedProc.pending_validations.size.should eq orig_pending/2 
  end
  it "displays links to completed procs, takes user to edit proc screen" do
    vn = Fabricate :v_nurse
    Fabricate(:nurse_1_proc, proc_name: 'PROC', q: 5)
    login vn
    click_link('PROC (5)')
    page.should have_content 'procedure'
  end

end