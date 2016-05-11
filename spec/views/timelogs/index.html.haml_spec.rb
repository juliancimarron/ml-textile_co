require 'rails_helper'

RSpec.describe "timelogs/index", type: :view do
  before(:each) do
    assign(:timelogs, [
      Timelog.create!(
        :employee => nil,
        :claim_status => "Claim Status"
      ),
      Timelog.create!(
        :employee => nil,
        :claim_status => "Claim Status"
      )
    ])
  end

  it "renders a list of timelogs" do
    render
    assert_select "tr>td", :text => nil.to_s, :count => 2
    assert_select "tr>td", :text => "Claim Status".to_s, :count => 2
  end
end
