




require 'spec_helper'

FIELD_ID = 'proc_name'
PROC_NAME = '_____procedure'
PROC_NAME2 = "#{PROC_NAME}2"

def login_nurse
  nurse = Fabricate(:nurse)
  login(nurse)
  nurse
end  

def click_on_popup_menu_item(item_name)
    sleep 1
    selector = ".ui-menu-item a:contains(\"#{item_name}\"):first"
    page.execute_script "$('#{selector}').trigger(\"mouseenter\").click();"
end

describe 'nurse completes procedure' do
	it 'redirects from login page for ordinary nurse' do
    login_nurse.validator?.should be_false
    page.should have_content 'add a procedure'
  end
  it 'selects properly from drop down list', :js => true do
    Fabricate :procedure, name: PROC_NAME
    
    login_nurse

    fill_in FIELD_ID, with: PROC_NAME[1..5]
    page.should have_text PROC_NAME
    fill_in FIELD_ID, with: PROC_NAME[-5, -1]
    page.should have_text PROC_NAME
  end
  it 'updates page with procedure options', js: true do 
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
