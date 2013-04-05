




require 'spec_helper'




def visit_home(*args)
  options = args.extract_options!
  n = args[0] || @n
  login n
  visit home_nurse_path n
  return n
end

def count_rows(id)
  page.all("table##{id} tr").count
end

describe "Nurse's home page", reset_db: false do
  before (:all) do
    reset_db

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

  def nurse_without status
    n = Fabricate :nurse
    (rand 1..10).times {n.completed_procs <<
        Fabricate(:rand_cp, status: (CP::STATUSES-[status]).sample)}
    return n
  end

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

  def click_and_wait_for_ajax
    # Click on something outside of auto-update fields
    find('h1').click
    page.has_no_css?('#topHeader img', visible: true).should be_true
  end
  
  describe "(personal info)", js: true do
    it "updates if fields are changed" do
      vn = visit_home Fabricate(:v_nurse)

      fill_in 'Designation', with: 'Test Designation'
      click_and_wait_for_ajax
      vn.reload.designation.should eq 'Test Designation'

      old_dept, new_dept = vn.dept.id.to_s
      # Choose something that's not selected.
      within '#nurse_dept_id' do
        new_dept = (all('option').map {|i| i[:value]} - [old_dept]).sample
        find("option[value='#{new_dept}']").select_option
      end
      click_and_wait_for_ajax
      vn.reload.dept.id.to_s.should eq new_dept

      fill_in 'nurse_comments', with: 'Test Comments'
      click_and_wait_for_ajax
      vn.reload.comments.should eq 'Test Comments'

      fill_in 'Email', with: 'test@example.com'
      click_and_wait_for_ajax
      vn.reload.email.should eq 'test@example.com'

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

  describe "(pending proc table)" do
    before (:each) do
      @TABLE = 'pendingValidationsTable'
    end
    it "has a header displaying total pending" do
      visit_home
      find('#pendingHeader').should have_text "validation (#{@q[CP::PENDING]})"
    end
    it "shows pending procs, with row for each pending (doesn't show other procs)" do
      visit_home
      count_rows(@TABLE).should eq @q[CP::PENDING]+1
    end
    it "doesn't show pending procs for a different nurse" do
      n2 = Fabricate :nurse_5_pending
      visit_home
      count_rows(@TABLE).should eq @q[CP::PENDING]+1
    end
    it "doesn't show table if no pending procs" do
      visit_home nurse_without CP::PENDING
      count_rows(@TABLE).should eq 0
    end
  end

  describe "(rejected proc table)" do
    before (:each) do
      @TABLE = 'rejectedTable'
    end
    it "has header displaying total rejected" do
      visit_home
      find('#rejectedHeader').should have_text "(#{@q[CP::REJECTED]})"
    end
    it "shows rejected procs, red row for each reject with name of validator" do 
      visit_home
      page.all("table##{@TABLE} a.rejected").count.should eq @q[CP::REJECTED]
      name = CP.where(status: CP::REJECTED).first.validated_by.first_name
      page.first("table##{@TABLE} td.val_by").text.should match /#{name}/
    end
    it "when link is clicked, update page should allow proc to be acknowledged" do
      visit_home @n
      proc1 = @n.completed_procs[0].procedure.name
      first("##{@TABLE} a").click
      page.has_css?('input [value="Acknowledge"]').should be_true
    end
    it "doesn't show table if no rejected procs" do
      visit_home nurse_without CP::REJECTED
      count_rows(@TABLE).should eq 0
    end
  end

  describe "(summary table)" do
    before (:each) do
      @TABLE = 'summaryTable'
    end
    it "shows count of each validated proc" do
      visit_home
      count_rows(@TABLE).should eq @q_valid.keys.count+1
      #This is kind of brittle, will change if table format changes.
      @n.completed_procs_summary.each do |proc_name, q|
        next unless q>0
        find("##{@TABLE}").text.should match /#{proc_name} +#{q}/
      end
    end
    it "doesn't show procs with 0 count" do
      visit_home
      name, q = @n.completed_procs_summary.find {|name, q| q==0}
      find("##{@TABLE}").text.should_not include name
    end
    it "doesn't show summary if no validated procs" do
      visit_home nurse_without CP::VALID
      count_rows(@TABLE).should eq 0
    end
  end

end
