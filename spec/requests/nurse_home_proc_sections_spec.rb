




require 'spec_helper'





shared_examples "a proc section" do

  let(:header_selector) {"h3##{o[:cp_type]}"}
  let(:table_selector) {"table##{o[:cp_type]}"}

  subject { visit_home @the_nurse ; find(header_selector).text }
  it { should include o[:header] }
  it { should include o[:total].to_s }

  # Check number of rows to make sure there isn't too much data in the table.
  it "(has table with correct number of rows)" do
    visit_home @the_nurse
    page.all("#{table_selector} tr").count.should eq (o[:n_rows] || o[:total])+1
  end
  it "(has table with appropriate data)" do
    visit_home @the_nurse
    o[:collection].each {|i| find(table_selector).text.should include "#{i[0]} #{i[1]}"}
  end
  it "(doesn't show table, instead shows some text if there's no rows)" do
    visit_home o[:owise_nurse]
    page.all("#{table_selector} tr").count.should eq 0
    find("#{header_selector} + .otherwise").should have_text o[:owise_text]
  end
end

def visit_home nurse
  login nurse
  visit home_nurse_path nurse
end

describe "Nurse home page", reset_db: false do 
  before(:all) do
    reset_db
    @the_nurse = Fabricate :nurse
    50.times { @the_nurse.completed_procs << Fabricate(:rand_cp, quantity: 1) }
    # Ensure we have at least one of each type of proc
    CP::STATUSES.each { |i| @the_nurse.completed_procs << Fabricate(:rand_cp, status: i) }
    @the_nurse.completed_procs <<  Fabricate(:rand_cp, status: CP::VALID, emergency: true)
  end

  def nurse_without status
    n = Fabricate :nurse
    (rand 1..5).times do
      n.completed_procs << Fabricate(:rand_cp, status: (CP::STATUSES-[status]).sample)
    end
    return n
  end

  describe "(pending proc table) -" do
    it_behaves_like "a proc section" do      
      let(:o) { {cp_type: 'pending',
       header: 'Procedures awaiting validation',
       total: @the_nurse.pendings.count,
       collection: @the_nurse.pendings.map {|cp| [cp.procedure.name, cp.date_start]},
       owise_nurse: nurse_without(CP::PENDING),
       owise_text: 'Nothing waiting for validation.'} }
     end
  end

  describe "(rejected proc table) -" do
    it_behaves_like "a proc section" do 
      let(:o) { {cp_type: 'rejected',
       header: 'Invalid procedures',
       total: @the_nurse.rejects.count,
       collection: @the_nurse.rejects.map {|cp| [cp.procedure.name, cp.date_start]},
       owise_nurse: nurse_without(CP::REJECTED),
       owise_text: 'No invalid procedures.'} }
    end
    it "has red rows in reject table" do
      visit_home @the_nurse
      page.should have_css "table#rejected a.rejected"
    end
    it "shows name of rejector in reject table" do
      visit_home @the_nurse
      name = CP.where(status: CP::REJECTED).first.validated_by.first_name
      page.first("table#rejected td.val_by").text.should match /#{name}/
    end
    it "when link is clicked, update page should allow proc to be acknowledged" do
      visit_home @the_nurse
      first("table#rejected a").click
      page.has_css?('input [value="Acknowledge"]').should be_true
    end
  end

  describe "(validated proc summary) -" do
    it_behaves_like "a proc section" do 
      let (:o) {{cp_type: 'completed',
       header: 'ummary',
       total: @the_nurse.completed_procs_total,
       collection: @the_nurse.completed_procs_summary,
       n_rows: @the_nurse.completed_procs_summary.size,
       owise_nurse: nurse_without(CP::VALID),
       owise_text: 'No completed procedures yet.'}}
     end
    it "procs that the nurse hasn't done don't appear" do
      visit_home @the_nurse
      Fabricate :procedure, name: 'Slice!'
      find("table#completed").text.should_not include 'Slice'
    end
  end

  describe "(emergency proc summary) -" do
    before(:all) do
      @no_emergencies = Fabricate :nurse
      10.times { @no_emergencies.completed_procs << Fabricate(:rand_cp, emergency: false) }
    end
    let(:summary) {@the_nurse.completed_procs_summary(emergency: true)}

    it_behaves_like "a proc section" do
      let(:o) {{cp_type: 'emergency',
       header: 'emergency',
       total: @the_nurse.completed_procs_total(emergency: true),
       collection: summary,
       n_rows: summary.size,
       owise_nurse: @no_emergencies,
       owise_text: 'emergency'}}
    end
    it "procs that the nurse hasn't done don't appear" do
      visit_home @the_nurse
      Fabricate :procedure, name: 'Dice!!'
      find("table#emergency").text.should_not include 'Dice!!'
    end
  end
end