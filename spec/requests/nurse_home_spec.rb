




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

describe "Nurse's home page" do
  before (:each) do
    @n = Fabricate :nurse
    
    #Adds completed procs to nurse.  @q hash contains number of procs for a given status
    @q = {}
    [CP::PENDING, CP::REJECTED, CP::ACK_REJECT].each do |status|
      (@q[status] = rand 1..10).times { 
        @n.completed_procs << Fabricate(:comp_proc_seq, status: status) }
    end

    #Adds a bunch of valid procs.  
    # @q_valid contains counts for each proc
    # q_valid[:nprocs] is number of different procs
    @q_valid = {}
    (@q_valid[:n_procs] = rand 1..10).times do |i|
      proc_name = "VALID#{i}"
      proc = Fabricate :procedure, name: proc_name
      (@q_valid[proc_name] = rand 1..10).times do
        @n.completed_procs << Fabricate(:completed_proc, 
                                        procedure: proc, 
                                        status: CP::VALID)
      end
    end
  end

  it "shows title for signed in nurse" do
    n = visit_home
    page.should have_text 'Home'
    page.should have_text n.first_name
  end
  #Fragile?  Needs something to check z-index issues, showed up as a bug previously.
  it "closes top accordion if header is clicked" do
    n = visit_home
    find('#topHeader').click
    find('#topHeader').should_not have_text 'Designation'
  end

  def click_and_wait_for_ajax
    find('h1').click
    page.has_no_css?('#topHeader img', visible: true).should be_true
  end
  
  describe "(personal info)", js: true do
    it "updates if fields are changed" do
      vn = visit_home Fabricate(:v_nurse)

      fill_in 'Designation', with: 'Test Designation'
      click_and_wait_for_ajax
      vn.reload.designation.should eq 'Test Designation'

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
      sleep 1 # Brittle.
      find('#topHeader img').visible?.should be_false
    end
  end

  describe "(completed proc table)" do
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
    it "doesn't show table if no completed procs" do
      @n.completed_procs.delete_all status: CP::PENDING
      visit_home
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
    it "shows rejected procs, red row for each reject" do 
      visit_home
      page.all("table##{@TABLE} a.rejected").count.should eq @q[CP::REJECTED]
    end
    it "when link is clicked, update page should allow proc to be acknowledged" do
      visit_home @n
      proc1 = @n.completed_procs[0].procedure.name
      first("##{@TABLE} a").click
      page.has_css?('input [value="Acknowledge"]').should be_true
    end
    it "doesn't show table if no rejected procs" do
      @n.completed_procs.delete_all status: CP::REJECTED
      visit_home
      count_rows(@TABLE).should eq 0
    end
  end

  describe "(summary table)" do
    before (:each) do
      @TABLE = 'summaryTable'
    end
    it "shows count of each validated proc" do
      visit_home
      count_rows(@TABLE).should eq @q_valid[:n_procs]+1
      #This is kind of brittle
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
      @n.completed_procs.delete_all status: CP::VALID
      visit_home
      count_rows(@TABLE).should eq 0
    end
  end

end
