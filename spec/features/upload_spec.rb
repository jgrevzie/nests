




require 'spec_helper'

describe "uploading a spreadsheet with nurses and procs" do
  
  def choose_file_and_submit
    attach_file 'Choose a spreadsheet to upload', TEST_XLS
    click_button 'Create Dept'
  end

  before(:each) do
    clear_db
    login Fabricate :v_nurse
    visit upload_depts_path
  end

  it "lets user select and upload a file" do
    n_procs, n_nurses = Procedure.count, Nurse.count
    choose_file_and_submit
    Procedure.count.should be > n_procs
    Nurse.count.should be > n_nurses
  end
  it "page has simple textarea that fills up with status info" do
    find_field('status').value.should eq ''
    #choose_file_and_submit
    #find_field('status').value.should_not eq ''
  end
  it "shows a pleasant error message if there's a problem with the dept" do
    choose_file_and_submit
    visit upload_depts_path
    # submit the same dept twice should give an error
    choose_file_and_submit
    page.should have_selector('#error_explanation')
  end
end
