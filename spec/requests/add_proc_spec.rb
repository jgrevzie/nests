




require 'spec_helper'

FIELD_ID = 'proc_name'
PROC_NAME = '_____procedure'
PROC_NAME2 = "#{PROC_NAME}2"

def login_nurse
  nurse = Fabricate :nurse
  login nurse
  nurse
end  

def click_on_popup_menu_item(item_name)
    sleep 1
    selector = ".ui-menu-item a:contains(\"#{item_name}\"):first"
    page.execute_script "$('#{selector}').trigger(\"mouseenter\").click();"
end

describe 'Submit comp proc for validation page' do
	it "is landing page if you're an ordinary nurse" do
    login_nurse.validator?.should be_false
    page.should have_content ApplicationHelper::SUBMIT_PROC_CONTENT
  end
  it "includes a shiny drop-down menu with known proc names", :js => true do
    Fabricate :procedure, name: PROC_NAME
    
    login_nurse

    fill_in FIELD_ID, with: PROC_NAME[1..5]
    page.should have_text PROC_NAME
    fill_in FIELD_ID, with: PROC_NAME[-5, -1]
    page.should have_text PROC_NAME
  end
  it "updates page with proc options, once a proc name is chosen from menu", js: true do 
    Fabricate :procedure, name: PROC_NAME, options: "option1, option2"
    Fabricate :procedure, name: PROC_NAME2, options: "checkbox?"

    login_nurse

    fill_in FIELD_ID, with: PROC_NAME
    click_on_popup_menu_item PROC_NAME
    page.should have_unchecked_field "option1"

    fill_in FIELD_ID, with: PROC_NAME2
    click_on_popup_menu_item PROC_NAME2
    page.should have_unchecked_field 'checkbox?'
  end
end
