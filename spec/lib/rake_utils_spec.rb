




require 'spec_helper'

describe RakeUtils do
  DIR_NAME = "#{Rails.root}/spec/data/nurse_images"

  def start_of_file(dir_index) 
    (File.open(Dir["#{DIR_NAME}/*.jpeg"][dir_index]) {|f| f.read})[0..10]
  end

  def stub_rand(value) Kernel.stub(:rand).and_return(value) end

  let(:n) {Fabricate :nurse}

  describe "photify_all" do
    it "photifies all known nurses" do
      stub_rand 1
      2.times {Fabricate :nurse}
      RakeUtils.photify_all
      Nurse.all.each {|n| n.mugshot.should be}
    end
  end

  describe "photify" do
    it "sometimes will setup a nil mugshot, to see whether the default nurse is rendered" do
      stub_rand 0
      RakeUtils.photify n
      n.mugshot.should eq nil
    end
    it "normally sets the mugshot to an image" do
      stub_rand 1
      RakeUtils.photify n
      # could remove the following, needs only to test for !nil because of other tests
      n.mugshot.should start_with start_of_file(1)
    end
  end
  describe "random_file" do
    it "returns data from a file in a directory" do
      stub_rand 0
      data = RakeUtils.random_file  DIR_NAME
      data.should start_with start_of_file(0)
    end
  end
end
