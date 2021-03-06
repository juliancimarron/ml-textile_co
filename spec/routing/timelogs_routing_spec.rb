require "rails_helper"

RSpec.describe TimelogsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/timelogs").to route_to("timelogs#index")
    end

    # it "routes to #new" do
    #   expect(:get => "/timelogs/new").to route_to("timelogs#new")
    # end

    it "routes to #show" do
      expect(:get => "/timelogs/1").to route_to("timelogs#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/timelogs/1/edit").to route_to("timelogs#edit", :id => "1")
    end

    # it "routes to #create" do
    #   expect(:post => "/timelogs").to route_to("timelogs#create")
    # end

    it "routes to #update via PUT" do
      expect(:put => "/timelogs/1").to route_to("timelogs#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/timelogs/1").to route_to("timelogs#update", :id => "1")
    end

    # it "routes to #destroy" do
    #   expect(:delete => "/timelogs/1").to route_to("timelogs#destroy", :id => "1")
    # end

    it "routes to #assistance" do
      expect(:get => "admin/reports/assistance").to route_to("timelogs#assistance")
    end

    it "routes to #reported_errors" do
      expect(:get => "admin/timelogs/reported_errors").to route_to("timelogs#reported_errors")
    end

    it "routes to #reported_error_update" do
      expect(:put => "admin/timelogs/reported_errors/1/update").to route_to("timelogs#reported_error_update", id: '1')
    end
  end
end
