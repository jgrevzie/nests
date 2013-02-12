




require 'spec_helper'




describe "nurse fabricator" do
  it 'fabricates nurses with random names' do
    nurse = Fabricate :nurse
  end
end

describe "nurse_5_procs fabricator" do
  it 'fabricates a nurse with a random name and 5 completed procs' do
    nurse5 = Fabricate :nurse_5_procs
    nurse5.completed_procs.count.should eq 5
  end
end

describe "head_nurse_5_subs fabricator" do
  it 'fabricates head nurse with 5 validatees and associated completed procs' do
    head = Fabricate :head_nurse_5_subs
    head.validatees.count.should eq 5
  end
end