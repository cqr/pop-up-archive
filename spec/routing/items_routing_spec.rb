require "spec_helper"

describe ItemsController do
  describe "routing" do

    it "routes to #index" do
      get("/items").should route_to("directory/items#index")
    end

    it "routes to #new" do
      get("/items/new").should route_to("directory/items#new")
    end

    it "routes to #show" do
      get("/items/1").should route_to("directory/items#show", :id => "1")
    end

    it "routes to #edit" do
      get("/items/1/edit").should route_to("directory/items#edit", :id => "1")
    end

    it "routes to #create" do
      post("/items").should route_to("directory/items#create")
    end

    it "routes to #update" do
      put("/items/1").should route_to("directory/items#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/items/1").should route_to("directory/items#destroy", :id => "1")
    end

  end
end
