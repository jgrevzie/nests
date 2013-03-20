




require 'spec_helper'

PROC_NAME = '_____procedure'
PROC_NAME2 = "#{PROC_NAME}2"

def login_new_nurse
  nurse = Fabricate :nurse
  login nurse
  nurse
end  

def comp_proc
  p = Fabricate :procedure, name: PROC_NAME, options: "option1, option2"
  cp = Fabricate :completed_proc, quantity: 7, date_start: Date.today-1, comments:'Hello', 
                 options: 'option1', procedure: p
end

def click_on_popup_menu_item(item_name)
    sleep 1
    selector = ".ui-menu-item a:contains(\"#{item_name}\"):first"
    page.execute_script "$('#{selector}').trigger(\"mouseenter\").click();"
end

def fill_in_proc_form(cp, *args)
  options = args.extract_options!
  fill_in 'Procedure Name', with: cp.procedure.name
  fill_in 'Date', with: cp.date_start
  fill_in 'How many of these procedures?', with: cp.quantity
  fill_in 'Comments', with: cp.comments
  choose cp.options if cp.options
  click_button 'submit' if options[:submit]
end

def procs_equiv?(cp_1, cp_2)
  ignore_attrs = ['_id', 'nurse_id']
  cp_1.attributes.except(*ignore_attrs) == cp_2.attributes.except(*ignore_attrs)
end

describe "'Submit proc for validation' page" do
	it "is landing page if you're an ordinary nurse" do
    login_new_nurse.validator?.should be_false
    page.should have_content ApplicationHelper::SUBMIT_PROC_CONTENT
  end
  it "includes a shiny drop-down menu with known proc names", :js => true do
    Fabricate :procedure, name: PROC_NAME
    
    login_new_nurse

    fill_in "Procedure Name", with: PROC_NAME[1..5]
    page.should have_text PROC_NAME
    fill_in "Procedure Name", with: PROC_NAME[-5, -1]
    page.should have_text PROC_NAME
  end
  it "updates page with proc options, once a proc name is chosen from menu", js: true do 
    Fabricate :procedure, name: PROC_NAME, options: "option1, option2"
    Fabricate :procedure, name: PROC_NAME2, options: "checkbox?"

    login_new_nurse

    fill_in "Procedure Name", with: PROC_NAME
    click_on_popup_menu_item PROC_NAME
    page.should have_unchecked_field "option1"

    fill_in "Procedure Name", with: PROC_NAME2
    click_on_popup_menu_item PROC_NAME2
    page.should have_unchecked_field 'checkbox?'
  end
  it "submits proc for validation, stores proc", js: true do
    login_new_nurse
    cp = comp_proc

    fill_in_proc_form cp, submit: true
    
    page.should have_content ApplicationHelper::SUBMIT_PROC_CONTENT
    page.should_not have_selector "#errorExplanation"
    page.should have_selector '#notice'
    page.should have_content ApplicationHelper::SUBMIT_PROC_CONTENT

    CompletedProc.pending.count.should eq 2    
    cp_out = CompletedProc.pending[1]
    procs_equiv?(cp, cp_out).should be_true
  end
  it "submits proc with unknown name, gets error" do
    login_new_nurse
    cp = Fabricate :completed_proc
    cp.procedure.name = 'NON-EXIST'

    fill_in_proc_form cp, submit: true
    page.should have_selector '#errorExplanation', text: 'Procedure'
  end
  it 'when updating, shows fields of previously entered completed proc' do 
    n = login_new_nurse
    cp = comp_proc
    n.completed_procs << cp
    visit edit_completed_proc_path(cp)
    page.should have_content "Edit procedure"
    fill_in_proc_form cp
    all("#options input[type='radio']").size.should eq cp.procedure.options.split(',').size
  end
  it "updates proc, and saves new values", js: true do
    n = login_new_nurse
    cp = comp_proc
    n.completed_procs << cp
    
    p2 = Fabricate :procedure, name: PROC_NAME2, options: "option4, option5"
    cp_2 = Fabricate :completed_proc, quantity: 1, date_start: Date.today-2, comments:'Later', 
                 options: 'option4', procedure: p2    
    
    visit edit_completed_proc_path(cp)
    fill_in_proc_form cp_2, submit: true
    page.should have_selector '#notice', text: 'Updated'

    cp.reload
    procs_equiv?(cp, cp_2).should be_true
  end
  it "lets VN validate a proc" do
    cp = comp_proc
    (Fabricate :nurse).completed_procs << cp

    login Fabricate :v_nurse
    visit edit_completed_proc_path(cp)
    choose 'Valid'
    click_button 'submit'
    page.should have_text ApplicationHelper::PENDING_VALIDATIONS
    CompletedProc.pending.size.should eq 0
  end
  it "let VN reject a proc, provding comments"
  it "saves VN as the validator of comp proc"
  it "lets nurse acknowledge a rejected proc"
  it "shows error message if proc name is invalid, disappears if it is valid", js: true do
    Fabricate :procedure, name: 'PROC'
    login Fabricate :nurse
    fill_in 'Procedure Name', with: 'this is not a procedure name'
    fill_in 'Comments', with: 'Look at that gorgeous error message.'
    find('#procError').should  be_visible
    fill_in 'Procedure Name', with: 'PROC'
    fill_in 'Comments', with: 'By gum, it seems to have vanished!!'
    find('#procError').should_not  be_visible
  end
  it "fixes proc name up a little, if it's on the dodgy side", js: true do
    Fabricate :procedure, name: 'Procedure Test'
    login Fabricate :nurse
    fill_in 'Procedure Name', with: 'procedure test'
    fill_in 'Comments', with: 'What a marvelous case correction scheme you have here.'
    find_field('Procedure Name').value.should eq 'Procedure Test'
  end

  def update_new_proc_with_old_date_and_submit(nurse)
    cp = comp_proc
    nurse.completed_procs << cp
    login nurse
    visit edit_completed_proc_path(cp)
    fill_in 'Date', with: CP::OLDEST_NEW_PROC-1
    click_button 'submit'
  end

  DATE_ERROR = 'Date start must be after'

  describe "invokes timliness checks that" do
    before(:each) do
      @old_proc = Fabricate :cp, date_start: CP::OLDEST_NEW_PROC-1, nurse: (Fabricate :nurse)
    end
    it "don't allow the creation of an old procedure by regular nurse" do
      login Fabricate :nurse
      visit new_completed_proc_path
      fill_in_proc_form @old_proc, submit: true
      find('#errorExplanation').should have_text DATE_ERROR
    end
    it "allow creation of old procedure by vn" do
      login Fabricate :v_nurse
      visit new_completed_proc_path
      fill_in_proc_form @old_proc, submit: true
      page.should have_no_selector('#errorExplanation')
    end
    it "don't allow update of old procedure by regular nurse" do
      update_new_proc_with_old_date_and_submit Fabricate :nurse
      find('#errorExplanation').should have_text DATE_ERROR
    end
    it "allow update of old proc by vn" do
      update_new_proc_with_old_date_and_submit Fabricate :v_nurse
      page.should have_no_selector('#errorExplanation')
    end
  end

end
