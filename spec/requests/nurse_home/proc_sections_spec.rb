



require 'spec_helper'

shared_examples "a proc section" do
  let(:header_selector) {"h3##{o[:cp_type]}"}
  let(:table_selector) {"table##{o[:cp_type]}"}

  subject { visit_home @the_nurse ; find(header_selector).text }
  it { should include o[:header] }
  it { should include (o[:total] || o[:collection].count).to_s }

  # Check number of rows to make sure there isn't too much data in the table.
  it "(has table with correct number of rows)" do
    visit_home @the_nurse
    page.all("#{table_selector} tr").count.should eq o[:collection].count+1
  end
  it "(has table with appropriate data)" do
    visit_home @the_nurse
    counts = o[:collection] 
    # Only tests that about 1/4 of the counts are there, for speed.
    counts.sample(counts.size/4).each {|i| find(table_selector).text.should include i.to_s}
  end
  it "(doesn't show table, instead shows some text if there's no rows)" do
    visit_home o[:owise_nurse]
    page.all("#{table_selector} tr").count.should eq 0
    find("#{header_selector} + .otherwise").should have_text o[:owise_text]
  end
end

shared_examples "a summary section" do |section_name|
  it "(procs that the nurse hasn't done don't appear)" do
    visit_home @the_nurse
    p = Fabricate :proc_seq
    find("table##{section_name}").text.should_not include p.name
  end
end

describe "Nurse home page", reset_db: false do 
  before(:all) do
    load_cathlab_procs
  
    # This nurse's procs shouldn't appear, unless there's some problem with the code.
    (Fabricate :nurse).completed_procs.concat Array.new(10){Fabricate :rand_cp}

    # Ensure we have at least one of each type of proc
    (@the_nurse=Fabricate :nurse).completed_procs << 
      Fabricate(:rand_cp, status: CP::VALID, emergency: true)
    CP::STATUSES.each { |i| @the_nurse.completed_procs << Fabricate(:rand_cp, status: i) }

    # Plus a bunch of randoms
    @the_nurse.completed_procs.concat Array.new(50){Fabricate :rand_cp}
  end

  def nurse_without status
    fabricate_cp = lambda {Fabricate(:rand_cp, 
                                    status: (CP::STATUSES-[status]).sample)}
    (n=Fabricate :nurse).completed_procs.concat Array.new(rand 1..10) {fabricate_cp.call}
    return n
  end

  describe "(pending proc table) -" do
    it_behaves_like "a proc section" do      
      let(:o) { {cp_type: 'pending',
       header: 'Procedures awaiting validation',
       collection: @the_nurse.pendings,
       owise_nurse: nurse_without(CP::PENDING),
       owise_text: 'Nothing waiting for validation.'} }
     end
  end

  describe "(rejected proc table) -" do
    it_behaves_like "a proc section" do 
      let(:o) { {cp_type: 'rejected',
       header: 'Invalid procedures',
       collection: @the_nurse.rejects,
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
      page.first("table#rejected td.validated_by").text.should match /#{name}/
    end
    it "when link is clicked, update page should allow proc to be acknowledged" do
      visit_home @the_nurse
      first("table#rejected a").click
      page.has_css?('input [value="Acknowledge"]').should be_true
    end
  end

  # Might be able to do the following without map, using hash as an array.
  def cp_summary(*filter)
    @the_nurse.completed_procs_summary(*filter).map {|name, n| "#{name} #{n}"}
  end
  def cp_total(*filter) 
    @the_nurse.completed_procs_total(*filter) 
  end

  describe "(validated proc summary) -" do
    it_behaves_like "a proc section" do 
      let (:o) {{cp_type: 'completed',
       header: 'ummary',
       total: cp_total,
       collection: cp_summary,
       owise_nurse: nurse_without(CP::VALID),
       owise_text: 'No completed procedures yet.'}}
    end
    it_behaves_like "a summary section", 'completed'
  end

  describe "(emergency proc summary) -" do
    let(:no_emergencies) do
      (n= Fabricate :nurse).completed_procs.concat Array.new(10){
        cp = Fabricate(:rand_cp, emergency: false)}
      return n
    end

    it_behaves_like "a proc section" do
      let(:o) {{cp_type: 'emergency',
       header: 'emergency',
       total: cp_total(emergency: true),
       collection: cp_summary(emergency: true),
       owise_nurse: no_emergencies,
       owise_text: 'emergency'}}
    end
    it_behaves_like "a summary section", 'emergency'
  end
end