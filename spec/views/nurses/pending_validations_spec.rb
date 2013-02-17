




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
    @nurse = Fabricate :nurse, validator: true
    @nurse.validatees << Fabricate(:nurse_1_proc, proc_name: 'PROC_NAME', q: 5)

    render
    rendered.should have_content "PROC_NAME (5)"
  end
end