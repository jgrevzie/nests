require "spec_helper"

describe DeptsController do
  describe "routing" do

    it "routes to #index" do
      get("/depts").should route_to("depts#index")
    end

    it "routes to #new" do
      get("/depts/new").should route_to("depts#new")
    end

    it "routes to #show" do
      get("/depts/1").should route_to("depts#show", :id => "1")
    end

    it "routes to #edit" do
      get("/depts/1/edit").should route_to("depts#edit", :id => "1")
    end

    it "routes to #create" do
      post("/depts").should route_to("depts#create")
    end

    it "routes to #update" do
      put("/depts/1").should route_to("depts#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/depts/1").should route_to("depts#destroy", :id => "1")
    end

  end
end
