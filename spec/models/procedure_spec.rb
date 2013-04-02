require 'spec_helper'






describe Procedure do

  describe "seed data" do
  	specify { Procedure.count.should > 0 }
  end

end
