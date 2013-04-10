




require 'spec_helper'





shared_examples "a proc section" do

  let(:header_selector) {"h3##{o[:cp_type]}"}
  let(:table_selector) {"table##{o[:cp_type]}"}

  subject { visit_home @the_nurse ; find(header_selector).text }
  it { should include o[:header] }
  it { should include o[:total].to_s }

  it "(has table with correct number of rows)" do
    visit_home @the_nurse
    page.all("#{table_selector} tr").count.should eq o[:total]+1
  end
  it "(has table with appropriate data)" do
    visit_home @the_nurse
    o[:collection].each {|i| find(table_selector).text.should include "#{i[0]} #{i[1]}"}
  end
  it "(shows no table and explanatory text in certain circumstances)" do
    visit_home o[:owise_nurse]
    p table_selector
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
  end

  def nurse_without status
    n = Fabricate :nurse
    (rand 1..5).times do
      n.completed_procs << Fabricate(:rand_cp, status: (CP::STATUSES-[status]).sample)
    end
    return n
  end

  describe "(pending proc table)" do

    it_behaves_like "a proc section" do      
      let(:o) { {cp_type: 'pending',
       header: 'Procedures awaiting validation',
       total: CP.where(status: CP::PENDING).count,
       collection: (CP.where(status: CP::PENDING).map {|cp| [cp.procedure.name, cp.date_start]}),
       owise_nurse: nurse_without(CP::PENDING),
       owise_text: 'Nothing waiting for validation.'} }
     end
  end

  # describe "(rejected proc table)" do
  #   it_behaves_like "a proc section", @the_nurse,
  #     {cp_type: 'rejected',
  #      header: 'Invalid procedures',
  #      total: CP.where(status: CP::REJECTED).count,
  #      collection: CP.where(status: CP::REJECTED).map {|cp| [cp.procedure.name, cp.date_start]},
  #      owise_nurse: nurse_without(CP::REJECTED),
  #      owise_text: 'No invalid procedures.'}
  #   it "has red rows in reject table" do
  #     visit_home @the_nurse
  #     page.should have_css "table#rejected a.rejected"
  #   end
  #   it "shows name of rejector in reject table" do
  #     name = CP.where(status: CP::REJECTED).first.validated_by.first_name
  #     page.first("table#rejected td.val_by").text.should match /#{name}/
  #   end
  #   it "when link is clicked, update page should allow proc to be acknowledged" do
  #     visit_home @the_nurse
  #     first("h3#rejected a").click
  #     page.has_css?('input [value="Acknowledge"]').should be_true
  #   end
  # end

  # describe "(validated proc summary)" do
  #   it_behaves_like "a proc section", @the_nurse,
  #     {cp_type: 'completed',
  #      header: 'ummary',
  #      total: CP.where(status: CP::VALID).count,
  #      collection: @the_nurse.completed_procs_summary(zeroes: false),
  #      owise_nurse: nurse_without(CP::VALID),
  #      owise_text: 'No completed procedures yet.'}
  #   it "procs that the nurse hasn't done don't appear" do
  #     visit_home @the_nurse
  #     name, q = @the_nurse.completed_procs_summary.find {|name, q| q==0}
  #     find("table#completed").text.should_not include name
  #   end
  # end

  # describe "(emergency proc summary)" do
  #   (no_emergencies = Fabricate :nurse)
  #   10.times { no_emergencies.completed_procs << Fabricate(:rand_cp, emergency: false) }

  #   it_behaves_like "a proc section", @the_nurse,
  #     {cp_type: 'emergency',
  #      header: 'emergency',
  #      total: CP.where(status: CP::VALID, emergency: true).count,
  #      collection: @the_nurse.completed_procs_summary(zeroes: false, emergency: true),
  #      owise_nurse: no_emergencies,
  #      owise_text: 'emergency'}
  #   it "procs that the nurse hasn't done don't appear" do
  #     visit_home @the_nurse
  #     name, q = @the_nurse.completed_procs_summary(emergency: true).find {|name, q| q==0}
  #     find("table#emergency").text.should_not include name
  #   end
  # end
end