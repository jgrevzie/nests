




require 'spec_helper'

PROC_NAME = '_____procedure'
PROC_NAME2 = "#{PROC_NAME}2"

def fill_in_proc_form(cp, *args)
  options = args.extract_options!
  fill_in 'Procedure Name', with: cp.proc.name
  fill_in 'Date', with: cp.date
  # click on procedure name again to hide date pop up
  find_field('Procedure Name').click

  check 'Emergency' if cp.emergency?
#  find('#completed_proc_emergency').trigger('click') if cp.emergency?
  fill_in 'How many of these procedures?', with: cp.quantity
  fill_in 'Comments', with: cp.comments
  choose cp.role
  choose cp.options if cp.options

  click_button 'submit' if options[:submit]
end

def procs_equiv?(cp_1, cp_2)
  ignore_attrs = ['_id', 'nurse_id']
  cp_1.attributes.except(*ignore_attrs) == cp_2.attributes.except(*ignore_attrs)
end

describe "'Submit proc for validation' page," do
  before(:all) do
    @dept = Fabricate :dept
    @p = Fabricate :procedure, name: PROC_NAME, options: "option1,option2", dept: @dept
    Fabricate :procedure, name: PROC_NAME2, options: "checkbox?", dept: @dept
    @cp = Fabricate :completed_proc, quantity: 7, date: Date.today-1, comments:'Hello', 
                   options: 'option1', emergency: true, role: CP::SCOUT, proc: @p
    # An old completed proc with a proc that has no options (means don't have to use js:true)
    @ancient_cp = Fabricate :cp, date: CP::OLDEST_NEW_PROC-1, nurse: @n, 
                            proc: (Fabricate :proc, dept: @dept)
    @n = Fabricate :nurse, dept: @dept
    @n.completed_procs << @cp
    @vn = Fabricate :v_nurse
  end
  before(:each) { login @n }
  # 'Regenerating' completed proc keeps appending a new cp to the end of @n.completed_procs
  let(:regen_cp) do
    (@n.completed_procs << 
      (Fabricate :rand_cp, status:CP::PENDING, comments:'Regen', options:'option1', proc:@p))[-1]
  end

# Following is for phantomjs driver
# def fill_in field, options
#   super
#   page.execute_script "$('label:contains(#{field})').siblings('input').keydown()"
# end
  def click_on_popup_menu_item(item_name)
    page.should have_text item_name
    selector = ".ui-menu-item a:contains(\"#{item_name}\"):first"
    page.execute_script "$('#{selector}').trigger(\"mouseenter\").click();"
  end

  describe "(javascript / ajax),", js:true do
    it "includes a shiny drop-down menu with known proc names", js:true do
      fill_in "Procedure Name", with: PROC_NAME[1..5]
      page.should have_text PROC_NAME
      fill_in "Procedure Name", with: PROC_NAME[-5, -1]
      page.should have_text PROC_NAME
    end
    # Skip the following test if necessary, because it's subsumed by other tests
    it "updates page with proc options, once a proc name is chosen from menu", skip:true do 
      # when clicking on drop-down
      fill_in "Procedure Name", with: PROC_NAME[1..5]
      click_on_popup_menu_item PROC_NAME
      page.should have_unchecked_field "option1"

      # when procedure field is left
      fill_in "Procedure Name", with: PROC_NAME2
      fill_in 'Comments', with: 'Good gravy, observe those dynamically updating options!'
      page.should have_unchecked_field 'checkbox?'
    end
    it "fixes proc name up a little, if it's on the dodgy side" do
      fill_in 'Procedure Name', with: PROC_NAME.upcase
      fill_in 'Comments', with: 'What a marvelous case correction scheme you have here.'
      find_field('Procedure Name').value.should eq PROC_NAME
    end
    
    let(:click_submit) do Proc.new do click_button('submit') end end
    REQD = 'This value is required'

    it "does client-side validation for Procedure Name" do
      check_client_side_error label: 'Procedure Name', with_bad: '', submit: click_submit, 
                              with_valid: PROC_NAME, error_div: '#procError', error: REQD
 
      check_client_side_error label: 'Procedure Name', with_bad: 'Reckless Chainsawing', 
                              submit: click_submit, with_valid: PROC_NAME, 
                              error_div: '#procError', error: 'Enter the name of a procedure.'
    end
    it "does client side validation for Date" do
      check_client_side_error label: 'Date', with_bad: '', submit: click_submit,
                              with_valid: Date.today.strftime('%d/%m/%Y'), error_div: '#dateError',
                              error: REQD
    end
    it "does client side date range checks, if user is not validator"
    it "does client side validation for Quantity" do
      Q_LABEL = 'How many of these procedures?'
      check_client_side_error label: Q_LABEL, with_bad: '', submit: click_submit, 
                              with_valid: 1, error_div: '#quantityError', error: REQD
      check_client_side_error label: Q_LABEL, with_bad: 0, submit: click_submit,
                              with_valid: 1, error_div: '#quantityError', 
                              error: 'This value should be greater than or equal to 1.'
      check_client_side_error label: Q_LABEL, with_bad: CP::MAX_PROCS_PER_DAY+1,
                              submit: click_submit, with_valid: 1, error_div: '#quantityError', 
                              error: 'This value should be lower than or equal to'
    end
    it "checks whether the user has selected a role, client side" do
      click_submit.call
      find('#roleErrors').text.length.should > 0
      choose 'Scrubbed'
      page.should_not have_selector '#roleErrors ul'
    end
    it "checks whether the user has selected a proc option, if the procedure has them" do
      fill_in 'Procedure Name', with: PROC_NAME
      fill_in 'Comments', with: 'just need to click outside proc name field'
      page.should have_selector '#options input'
      click_submit.call
      find('#optionErrors').should have_text 'Please choose an option.'
      choose 'option1'
      page.should_not have_selector '#optionErrors ul'

    end
  end

  describe "(saving / updating)," do
    it "submits proc for validation, stores proc" , js:true do
      pendings_orig = CP.pending.count
      fill_in_proc_form @cp, submit: true
      
      page.should have_content 'Submit Procedure'
      page.should_not have_selector "#errorExplanation"
      page.should have_selector '#notice'

      CompletedProc.pending.count.should eq pendings_orig+1    
      cp_out = CompletedProc.pending[-1]
      procs_equiv?(@cp, cp_out).should be_true
    end
    it "submits proc with unknown name, gets error" do
      # Warning - do not use that proc_name: option to fabricator or the proc _will_ exist :)
      nonexist = Fabricate :completed_proc
      nonexist.proc.name = 'NON_EXIST'
      nonexist.options = nil
      fill_in_proc_form nonexist, submit: true
      page.should have_selector '#errorExplanation', text: 'Proc'
    end
    it 'when updating, shows fields of previously entered completed proc' do 
      visit edit_completed_proc_path(@cp)
      page.should have_content "Edit procedure"
      find_field('Comments').value.should eq @cp.comments
      find_field('How many of these procedures').value.should eq @cp.quantity.to_s
      page.has_checked_field? @cp.options
      all("#options input[type='radio']").size.should eq @cp.proc.options.split(',').size
    end
    it "updates proc, and saves new values", js: true do
      p = Fabricate :proc, name: 'Walk Pooch', options: 'option4,option5'
      cp_2 = Fabricate :completed_proc, quantity: 1, date: Date.today-2, comments:'Later tater.', 
                   options: 'option4', emergency: true, role: CP::SCOUT, proc: p
      
      visit edit_completed_proc_path(@cp)
      fill_in_proc_form cp_2, submit: true
      page.should have_selector '#notice', text: 'Updated'

      @cp.reload
      procs_equiv?(@cp, cp_2).should be_true
    end
  end
  describe "(validation / rejection / acknowledgement / obsession)" do
    before (:all) { @vn = Fabricate :v_nurse }
    it "lets VN validate a proc, validate radio button is selcted by default" do
      pendings_orig = CP.pendings.count
      login @vn
      visit edit_completed_proc_path(regen_cp)
      page.should have_checked_field "Validate"
      click_button 'submit'
      on_pending_vn_page?.should be_true
      # regen_cp reference would have added a pending cp, and submitting would have removed it
      CompletedProc.pending.size.should eq pendings_orig
    end
    it "let VN reject a proc, provding comments and saving VN as validator" do
      login @vn
      visit edit_completed_proc_path(regen_cp)
      fill_in 'Comments', with: 'Nurse should not use chainsaw so recklessly.'
      choose 'Reject'
      click_on 'submit'
      regen_cp.reload.rejected?.should be_true
      regen_cp.comments.should match /chainsaw/
      regen_cp.validated_by.id.should eq @vn.id
    end
    it "lets nurse acknowledge a rejected proc, page should contain name of validator" do 
      pendings_orig = CP.pendings.count
      regen_cp.reject @vn ; regen_cp.save
      visit edit_completed_proc_path regen_cp
      find('.rejected').text.should match /#{@vn.first_name}/
      click_on 'Acknowledge'
      CP.pendings.count.should eq pendings_orig
      regen_cp.reload.ackd?.should be_true
    end
    it "doesn't show options to ack/reject if it's a new proc" do
      login @vn
      visit new_completed_proc_path
      page.should have_no_checked_field "Validate"
    end
    it "doesn't let regular nurse ack/reject" do
      visit edit_completed_proc_path @cp
      page.should have_no_checked_field "Validate"
    end
    it "doesn't let regular nurse edit a validated proc" do
      (regen_cp.vdate @vn).save
      visit edit_completed_proc_path regen_cp
      page.should have_css "div.dont-belong"
    end
  end

  def update_new_proc_with_old_date_and_submit(nurse)
    login nurse
    visit edit_completed_proc_path(regen_cp)
    fill_in 'Date', with: CP::OLDEST_NEW_PROC-1
    click_button 'submit'
  end

  DATE_ERROR = 'Date must be after'

  describe "invokes timliness checks that" do
    it "don't allow the creation of an old procedure by regular nurse" do
      login Fabricate :nurse
      visit new_completed_proc_path
      fill_in_proc_form @ancient_cp, submit: true
      find('#errorExplanation').should have_text DATE_ERROR
    end
    it "allow creation of old procedure by vn" do
      login @vn
      visit new_completed_proc_path
      fill_in_proc_form @ancient_cp, submit: true
      page.should have_no_selector('#errorExplanation')
    end
    it "don't allow update of old procedure by regular nurse" do
      update_new_proc_with_old_date_and_submit @n
      find('#errorExplanation').should have_text DATE_ERROR
    end
    it "allow update of old proc by vn" do
      update_new_proc_with_old_date_and_submit @vn
      page.should have_no_selector('#errorExplanation')
    end
  end

end
