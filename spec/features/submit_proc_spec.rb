




require 'spec_helper'

PROC_NAME = '_____procedure'
PROC_NAME2 = "#{PROC_NAME}2"

def click_on_popup_menu_item(item_name)
    sleep 1
    selector = ".ui-menu-item a:contains(\"#{item_name}\"):first"
    page.execute_script "$('#{selector}').trigger(\"mouseenter\").click();"
end

def fill_in_proc_form(cp, *args)
  options = args.extract_options!
  fill_in 'Procedure Name', with: cp.proc.name
  fill_in 'Date', with: cp.date
  fill_in 'How many of these procedures?', with: cp.quantity
  fill_in 'Comments', with: cp.comments
#  find('#completed_proc_emergency').trigger('click') if cp.emergency?
  check 'Emergency' if cp.emergency?
  choose cp.role
  choose cp.options if cp.options
  click_button 'submit' if options[:submit]
end

def procs_equiv?(cp_1, cp_2)
  ignore_attrs = ['_id', 'nurse_id']
  cp_1.attributes.except(*ignore_attrs) == cp_2.attributes.except(*ignore_attrs)
end

describe "'Submit proc for validation' page" do
# def fill_in field, options
#   super
#   page.execute_script "$('label:contains(#{field})').siblings('input').keydown()"
# end

  before(:each) { clear_db }
  let(:dept) {Fabricate :dept}
  let!(:proc1) {Fabricate :procedure, name: PROC_NAME, options: "option1,option2", dept: dept}
  let!(:proc2) {Fabricate :procedure, name: PROC_NAME2, options: "checkbox?", dept: dept}
  let(:cp) do
    Fabricate :completed_proc, quantity: 7, date: Date.today-1, comments:'Hello', 
              options: 'option1', emergency: true, role: CP::SCOUT, proc: proc1
  end
  let!(:n) { login Fabricate :nurse, dept: dept }

  it "includes a shiny drop-down menu with known proc names", :js => true do
    fill_in "Procedure Name", with: PROC_NAME[1..5]
    page.should have_text PROC_NAME
    fill_in "Procedure Name", with: PROC_NAME[-5, -1]
    page.should have_text PROC_NAME
  end
  # Skip the following test, because it's subsumed by the one after it and several others
  it "updates page with proc options, once a proc name is chosen from menu", js:true,skip:true do 
    fill_in "Procedure Name", with: PROC_NAME
    click_on_popup_menu_item PROC_NAME
    page.should have_unchecked_field "option1"

    fill_in "Procedure Name", with: PROC_NAME2
    click_on_popup_menu_item PROC_NAME2
    page.should have_unchecked_field 'checkbox?'
  end
  it "submits proc for validation, stores proc" , js:true do
    fill_in_proc_form cp, submit: true
    
    page.should have_content 'Submit Procedure'
    page.should_not have_selector "#errorExplanation"
    page.should have_selector '#notice'

    CompletedProc.pending.count.should eq 2    
    cp_out = CompletedProc.pending[1]
    procs_equiv?(cp, cp_out).should be_true
  end
  it "submits proc with unknown name, gets error" do
    # Warning - do not use that proc_name: option or the proc _will_ exist :)
    nonexist = Fabricate :completed_proc
    nonexist.proc.name = 'NON_EXIST'
    nonexist.options = nil
    fill_in_proc_form nonexist, submit: true
    page.should have_selector '#errorExplanation', text: 'Proc'
  end
  it 'when updating, shows fields of previously entered completed proc' do 
    n.completed_procs << cp
    visit edit_completed_proc_path(cp)
    page.should have_content "Edit procedure"
    find_field('Comments').value.should eq cp.comments
    find_field('How many of these procedures').value.should eq cp.quantity.to_s
    page.has_checked_field? cp.options
    all("#options input[type='radio']").size.should eq cp.proc.options.split(',').size
  end
  it "updates proc, and saves new values", js: true do
    n.completed_procs << cp
    p = Fabricate :proc, name: 'Walk Pooch', options: 'option4,option5'
    cp_2 = Fabricate :completed_proc, quantity: 1, date: Date.today-2, comments:'Later', 
                 options: 'option4', emergency: true, role: CP::SCOUT, proc: p
    
    visit edit_completed_proc_path(cp)
    fill_in_proc_form cp_2, submit: true
    page.should have_selector '#notice', text: 'Updated'

    cp.reload
    procs_equiv?(cp, cp_2).should be_true
  end
  it "lets VN validate a proc" do
    (Fabricate :nurse).completed_procs << cp

    login Fabricate :v_nurse
    visit edit_completed_proc_path(cp)
    choose 'Valid'
    click_button 'submit'
    on_pending_vn_page?.should be_true
    CompletedProc.pending.size.should eq 0
  end
  it "let VN reject a proc, provding comments and saving VN as validator" do
    (Fabricate :nurse).completed_procs << cp
    vn = login Fabricate :v_nurse
    visit edit_completed_proc_path(cp)
    find_field('Comments').value.should eq cp.comments
    fill_in 'Comments', with: 'Nurse should not use chainsaw so recklessly.'
    choose 'Reject'
    click_on 'submit'
    cp.reload.rejected?.should be_true
    cp.comments.should match /chainsaw/
    cp.validated_by.id.should eq vn.id
  end
  it "lets nurse acknowledge a rejected proc, page should contain name of validator" do 
    cp.reject vn=Fabricate(:v_nurse)
    (n = login Fabricate(:nurse)).completed_procs << cp
    visit edit_completed_proc_path cp
    find('.rejected').text.should match /#{vn.first_name}/
    click_on 'Acknowledge'
    CP.pendings.count.should eq 0
    cp.reload.ackd?.should be_true
  end
  it "shows error message if proc name is invalid, disappears if it is valid", js: true do
    fill_in 'Procedure Name', with: 'this is not a procedure name'
    fill_in 'Comments', with: 'Look at that gorgeous error message.'
    find('#procError').should  be_visible
    fill_in 'Procedure Name', with: PROC_NAME
    fill_in 'Comments', with: 'By gum, it seems to have vanished!!'
    #page.should have_no_css '#procError'
    find('#procError').should_not  be_visible
  end
  it "fixes proc name up a little, if it's on the dodgy side", js: true do
    fill_in 'Procedure Name', with: PROC_NAME.upcase
    fill_in 'Comments', with: 'What a marvelous case correction scheme you have here.'
    find_field('Procedure Name').value.should eq PROC_NAME
  end

  def update_new_proc_with_old_date_and_submit(nurse)
    nurse.completed_procs << cp
    login nurse
    visit edit_completed_proc_path(cp)
    fill_in 'Date', with: CP::OLDEST_NEW_PROC-1
    click_button 'submit'
  end

  DATE_ERROR = 'Date must be after'

  describe "invokes timliness checks that" do
    # An old completed proc with a proc that has no options (means don't have to use js:true)
    let(:old_cp) {Fabricate :cp, date: CP::OLDEST_NEW_PROC-1, nurse: n, 
                              proc: (Fabricate :proc, dept: dept)}
    it "don't allow the creation of an old procedure by regular nurse" do
      login Fabricate :nurse
      visit new_completed_proc_path
      fill_in_proc_form old_cp, submit: true
      find('#errorExplanation').should have_text DATE_ERROR
    end
    it "allow creation of old procedure by vn" do
      login Fabricate :v_nurse
      visit new_completed_proc_path
      fill_in_proc_form old_cp, submit: true
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