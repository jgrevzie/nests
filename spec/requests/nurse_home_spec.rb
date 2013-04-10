




require 'spec_helper'







describe "Nurse's home page", reset_db: false do

  def visit_home(*args)
    options = args.extract_options!
    n = args[0] || @n
    login n
    visit home_nurse_path n
    return n
  end

  before (:all) do
    puts "BEEBO!"
    clear_db

    # Builds sample completed procs.  @q hash contains number of procs for a given status
    @q = {}
    @comp_procs = []
    [CP::PENDING, CP::REJECTED, CP::ACK_REJECT].each do |status|
      (@q[status] = rand 1..5).times { @comp_procs << Fabricate(:comp_proc_seq, status: status) }
    end

    # Adds a large number of valid procs.  
    # @q_valid contains counts for each proc type (n = @q_valid[proc_name])
    @q_valid = {}
    (rand 1..10).times do |i|
      proc_name = "VALID#{i}"
      proc = Fabricate :procedure, name: proc_name
      (@q_valid[proc_name] = rand 1..5).times do
        @comp_procs << Fabricate(:completed_proc, procedure: proc, status: CP::VALID)
      end
    end
  end
  before (:each) {(@n = Fabricate :nurse).completed_procs << @comp_procs}

  it "shows title for signed in nurse" do
    n = visit_home
    page.should have_text 'Home'
    page.should have_text n.first_name
  end
  #Fragile?  Needs something to check z-index issues (have already shown up as bugs).
  it "closes top accordion if header is clicked" do
    n = visit_home
    find('#topHeader').click
    find('#topHeader').should_not have_text 'Designation'
  end
  it "on_pending_vn_page? won't detect 'Pending Validations' on horizontal toolbar" do
    visit_home
    on_pending_vn_page?.should be_false
  end

  describe "(personal info)", js: true do
    let(:vn) {visit_home Fabricate(:v_nurse)}
    def click_and_wait_for_ajax
      # Click on something outside of auto-update fields.
      find('h1').click
      # Wait for the spinner to disappear.
      page.has_no_css?('#topHeader img', visible: true).should be_true
    end      
    def check_autoupdate_field *args
      o = args.extract_options!
      fill_in o[:label], with: o[:with]
      click_and_wait_for_ajax
      vn.reload.send(o[:attr]).should eq o[:with]
    end

    it "updates if fields are changed" do
      visit_home vn
      check_autoupdate_field label: 'Name', with: 'Naughty Nurse', attr: :name
      check_autoupdate_field label: 'Designation', with: 'Test Desig', attr: :designation

      old_dept, new_dept = vn.dept.id.to_s
      # Choose something that's not selected.
      within '#nurse_dept_id' do
        new_dept = (all('option').map {|i| i[:value]} - [old_dept]).sample
        find("option[value='#{new_dept}']").select_option
      end
      click_and_wait_for_ajax
      vn.reload.dept.id.to_s.should eq new_dept

      check_autoupdate_field label: 'nurse_comments', with: 'Hello nurse!', attr: :comments
      check_autoupdate_field label: 'Email', with: 't@example.com', attr: :email

      check 'Receive daily emails?'
      click_and_wait_for_ajax
      vn.reload.wants_mail.should be_true
    end
    it "doesn't show checkbox to receive mail, unless validator" do
      n = visit_home
      page.should have_no_css('#wants_mail')
    end
    it "shows spinning wheel while changes are being made", js: true do
      vn = visit_home Fabricate(:v_nurse)
      check 'Receive daily emails?'
      find('#topHeader img').visible?.should be_true
      # Wait till image disappears.
      page.has_no_css?('#topHeader img', visible: true).should be_true
    end
  end


end
