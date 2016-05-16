require "rails_helper"

RSpec.describe PagesController, type: :routing do

  describe "routing" do
    it "routes to #root_proxy" do
      expect(:get => "/").to route_to("pages#root_proxy")
    end
  end
  
end
