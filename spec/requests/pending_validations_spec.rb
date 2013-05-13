require 'spec_helper'



describe "'Pending validations for nurse' screen", reset_db: false do
  before(:all) {load_cathlab_procs}
  let(:n_pendings) {CompletedProc.pending_validations.count}

  it 'displays a table with a row for each pending proc, shows # of procs' do
    vn = Fabricate :v_nurse

    Fabricate :nurse_1_proc, proc_name: 'PROC_NAME', q: 5

    login vn
    on_pending_vn_page?.should be_true
    page.all('table#pendingValidationsTable tr').count.should eq n_pendings+1
    page.should have_content "PROC_NAME (5)"
  end
  it "validates all procs if submit button is clicked" do
    np_orig = CompletedProc.pending_validations.count

    vn = Fabricate :v_nurse
    Fabricate :nurse_5_pendings
    
    CompletedProc.pending_validations.count.should eq np_orig+5
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

    login vn

    np_orig = vn.pendings.count
    vn.pendings.sample(np_orig/2).each do |proc|
      uncheck "proc_ids[#{proc._id}]"
    end
     
    click_button 'Validate Checked'
    vn.pendings.size.should eq np_orig/2 
  end
  it "displays links to completed procs, takes user to edit proc screen" do
    vn = Fabricate :v_nurse
    Fabricate(:nurse_1_proc, proc_name: 'PROC', q: 5)
    login vn
    click_link('PROC (5)')
    page.should have_content 'procedure'
  end

end