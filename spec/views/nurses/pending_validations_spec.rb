




require 'spec_helper'




describe 'nurses/pending_validations' do
 it 'contains main table that displays a line per pending proc' do
  @nurse = Fabricate :head_nurse_5_subs
  render

  n_procs_pending_validation = @nurse.all_validatee_procs_pending_validation.size
  n_procs_pending_validation.should eq 25

  rendered.should have_selector 'table#pendingValidationsTable tr', 
    count: n_procs_pending_validation+1
  end
  it 'indicates procs with quantity greather than 1' do
    proc = Fabricate :procedure, name: 'PROC_NAME'
    cp = Fabricate :completed_proc, quantity: 5, procedure: proc
    sub_nurse = Fabricate :nurse
    sub_nurse.completed_procs << cp
    
    @nurse = Fabricate :nurse, validator: true
    @nurse.validatees << sub_nurse

    render
    rendered.should have_content "PROC_NAME (5)"
  end
end