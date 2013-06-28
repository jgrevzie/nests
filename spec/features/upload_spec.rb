




require 'spec_helper'

describe "Uploading a spreadsheet containing nurses and procs" do
  
  def choose_file_and_submit *file_name
    attach_file 'Choose a spreadsheet to upload', (file_name[0] || TEST_XLS)
    click_button 'submitButton'
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
  it "shows a pleasant error message if there's a problem with the dept" do
    choose_file_and_submit
    visit upload_depts_path
    # submit the same dept twice should give an error
    choose_file_and_submit
    page.should have_selector('#error_explanation')
    # COULD TEST WHAT PAGE WE'RE ON
  end
  it "if there's errors with nurses or procs, upload continues but errors are displayed later" do
    n_depts = Dept.count
    choose_file_and_submit "#{DATA_DIR}/no_nurse_sheet.xls"
    Dept.count.should eq n_depts+1
    page.should have_selector '#upload_errors'
  end
end
