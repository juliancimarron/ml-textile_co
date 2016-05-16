require 'rails_helper'

RSpec.describe "timelogs/edit", type: :view do

  fixtures :timelogs
  fixtures :employees

  before(:each) do
    sign_in employees(:john)
    @timelog = timelogs(:john)
    @period = 'This is the pay period'
  end

  describe 'form to enter claim data' do
    specify { expect(render).to have_css '.top-bar', count: 1 }
    specify { expect(render).to have_text @period }
    specify { expect(render).to have_css 'form input[type="submit"]', count: 1 }
    specify { expect(render).to have_text (DateTime.new(2016) + @timelog.arrive_sec.seconds).strftime '%l:%M %p' }
    specify { text = (DateTime.new(2016) + @timelog.claim_arrive_sec.seconds).strftime('%l:%M %p')
      expect(render).to have_css "input[type='text'][value='#{text}']"}
  end

end
