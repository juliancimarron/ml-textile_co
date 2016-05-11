require 'rails_helper'

RSpec.describe "_alert_warning", type: :view do

  it "displays callouts if there is a notice" do
    notice = 'This is a test'
    flash[:notice] = notice
    expect(render).to have_css '.callout.primary', text: notice
    expect(render).not_to have_css '.callout.warning'
  end

  it "displays callouts if there is an alert" do
    alert = 'This is a test'
    flash[:alert] = alert
    expect(render).to have_css '.callout.warning', text: alert
    expect(render).not_to have_css '.callout.primart'
  end

end
