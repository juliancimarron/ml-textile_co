require 'rails_helper'

RSpec.describe "timelogs/show", type: :view do
  before(:each) do
    @timelog = assign(:timelog, Timelog.create!(
      :employee => nil,
      :claim_status => "Claim Status"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(//)
    expect(rendered).to match(/Claim Status/)
  end
end
