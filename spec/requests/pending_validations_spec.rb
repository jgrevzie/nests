require 'spec_helper'



describe "'Pending validations for nurse' screen" do
  before(:all) do
    # Fabricate another department and a bunch of random procs to try to trick the tests.
    dept = Fabricate :dept, name: 'Woolens'
    10.times {Fabricate :rand_cp, dept: dept}
  end
  let(:table_rows) {page.all('table#pendingValidationsTable tr').count}
  it 'displays a table with a row for each pending proc, shows caption with # of procs' do
    vn = Fabricate :v_nurse
    Fabricate :nurse_1_proc, proc_name: 'PROC_NAME', quantity: 5
    Fabricate :rand_cp, status: CP::PENDING, dept: Fabricate(:dept, name: 'hello')

    login vn
    on_pending_vn_page?.should be_true

    find('caption').text.should =~ /total 1/
    table_rows.should eq vn.procs_i_can_validate.count+1
    page.should have_content "PROC_NAME (5)"
  end
  it "validates all procs if submit button is clicked" do
    vn = Fabricate :v_nurse
    np_orig = vn.procs_i_can_validate.count

    Fabricate :nurse_5_pendings
    vn.procs_i_can_validate.count.should eq np_orig+5

    login vn
    on_pending_vn_page?.should be_true
    click_button 'Validate Checked'
    
    vn.procs_i_can_validate.count.should eq 0
  end
  it "shouldn't give an error screen if there's nothing to validate" do
    (vn = Fabricate :v_nurse).validate_all
    login vn

    on_pending_vn_page?.should be_true
    table_rows.should eq 1
    click_button 'Validate Checked'
  end
  it "validates a subset of total procs" do
    vn = Fabricate :v_nurse
    2.times { Fabricate :nurse_5_pendings }
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
    Fabricate(:nurse_1_proc, proc_name: 'PROC', quantity: 5)
    login vn
    click_link('PROC (5)')
    page.should have_content 'procedure'
  end

end