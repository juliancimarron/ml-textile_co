require 'rails_helper'

RSpec.describe "timelogs/edit", type: :view do

  fixtures :timelogs
  fixtures :timesheets
  fixtures :employees

  before(:each) do
    sign_in employees(:john)
    @timelog = timelogs(:john)
    @timesheet = timesheets(:john)
  end

  describe 'form to enter claim data' do
    specify { expect(render).to have_css '.top-bar', count: 1 }
    specify { expect(render).to have_text Timesheet.print_timesheet_period(@timesheet) }
    specify { expect(render).to have_css 'form input[type="submit"]', count: 1 }
    specify { expect(render).to have_text (@timelog.log_date + @timelog.arrive_sec).strftime '%l:%M %p' }
    specify { text = (@timelog.log_date + @timelog.claim_arrive_sec).strftime('%l:%M %p')
      expect(render).to have_css "input[type='text'][value='#{text}']"}
  end

end
