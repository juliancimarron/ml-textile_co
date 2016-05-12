require "rails_helper"

RSpec.describe TimesheetsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/timesheets").to route_to("timesheets#index")
    end

    it "routes to #new" do
      expect(:get => "/timesheets/new").to route_to("timesheets#new")
    end

    it "routes to #show" do
      expect(:get => "/timesheets/1").to route_to("timesheets#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/timesheets/1/edit").to route_to("timesheets#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/timesheets").to route_to("timesheets#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/timesheets/1").to route_to("timesheets#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/timesheets/1").to route_to("timesheets#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/timesheets/1").to route_to("timesheets#destroy", :id => "1")
    end

  end
end
