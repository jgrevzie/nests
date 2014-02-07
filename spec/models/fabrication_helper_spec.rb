




require 'spec_helper'
require "#{Rails.root}/spec/fabricators/fabricator_helper_fabricator.rb"

describe "fabricator helper" do
  describe "opt_params" do
    it "returns slice of initial hash if there's just a list of symbols" do
      opt_params({a:1, b:2, c:3, d:4}, :a, :b).should == {a:1, b:2}
    end
    it "translates keys if there's a mapping at the end of the params" do 
      opt_params({a:1, b:2, c:3, d:4}, a: :apple, b: :banana).should == {apple:1, banana:2}
    end
    it "doesn't add empty values to hash" do
      opt_params({a:1}, b: :banana).should == {}
    end
    it "allows list of keys and then a hash of mappings" do
      opt_params({a:1, b:2}, :a, b: :banana).should == {a:1, banana: 2}
    end
    it "ignores null values in input hash" do
      opt_params({a:1}, :a, :b).should == {a:1}
    end
    it "ought to show a warning" do
      opt_params({a: nil, b: :banana}, :c, a: :apple)
    end
  end
end
