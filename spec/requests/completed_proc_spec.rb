




require 'spec_helper'

PROC_FIELD = 'Procedure Name'
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

describe "'Submit proc for validation' page" do
	it "is landing page if you're an ordinary nurse" do
    login_new_nurse.validator?.should be_false
    page.should have_content ApplicationHelper::SUBMIT_PROC_CONTENT
  end
  it "includes a shiny drop-down menu with known proc names", :js => true do
    Fabricate :procedure, name: PROC_NAME
    
    login_new_nurse

    fill_in PROC_FIELD, with: PROC_NAME[1..5]
    page.should have_text PROC_NAME
    fill_in PROC_FIELD, with: PROC_NAME[-5, -1]
    page.should have_text PROC_NAME
  end
  it "updates page with proc options, once a proc name is chosen from menu", js: true do 
    Fabricate :procedure, name: PROC_NAME, options: "option1, option2"
    Fabricate :procedure, name: PROC_NAME2, options: "checkbox?"

    login_new_nurse

    fill_in PROC_FIELD, with: PROC_NAME
    click_on_popup_menu_item PROC_NAME
    page.should have_unchecked_field "option1"

    fill_in PROC_FIELD, with: PROC_NAME2
    click_on_popup_menu_item PROC_NAME2
    page.should have_unchecked_field 'checkbox?'
  end
  it "submits proc for validation, stores proc", js: true do
    login_new_nurse
    cp = comp_proc

    fill_in 'Procedure Name', with: cp.procedure.name
    click_on_popup_menu_item cp.procedure.name
    fill_in 'Date', with: cp.date_start
    fill_in 'How many of these procedures?', with: cp.quantity
    fill_in 'Comments', with: cp.comments
    choose cp.options
    click_button 'submit'
    
    page.should have_content ApplicationHelper::SUBMIT_PROC_CONTENT
    CompletedProc.pending.count.should eq 2
    
    cp_out = CompletedProc.pending[1]
    cp_out.procedure.name.should eq cp.procedure.name
    cp_out.date_start.should eq cp.date_start
    cp_out.quantity.should eq cp.quantity
    cp_out.comments.should eq cp.comments
    cp_out.options.should eq cp.options
  end
  it 'displays completed procedure on update' do 
    n = login_new_nurse
    cp = comp_proc
    n.completed_procs << cp
    visit edit_completed_proc_path(cp)
    page.should have_content "Edit Procedure"
    find_field("Procedure Name").value.should eq cp.procedure.name
    find_field("Date").value.should eq cp.date_start.strftime '%d/%m/%Y'
    find_field("How many of these procedures?").value.should eq cp.quantity.to_s
    find_field("Comments").value.should eq cp.comments
    all("#options input[type='radio']").size.should eq cp.procedure.options.split(',').size

  end
end
