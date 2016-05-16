require 'rails_helper'
require 'support/shared_context'

RSpec.describe "timelogs/index", type: :view do
  include_context 'create_timelogs'

  fixtures :employees

  describe "renders the signed in employee's timelogs" do
    def calc_business_days(start_date, end_date) 
      date = start_date
      business_days = 0
      while date <= end_date
        business_days += 1 unless [6,7].include? date.cwday
        date += 1.day
      end
    end

    let(:start_date) { Date.new(2016,5,1) }
    let(:end_date) { Date.new(2016,5,10) }
    let(:workdays) { calc_business_days(start_date, end_date) }
    let(:employee) { employees(:john) }

    before(:example) do
      sign_in employee

      create_timelogs(start_date, end_date, employee)

      @timelogs = Timelog.all
      @periods = {collection: [['Period 1 Title'], ['2016-05-01']], last: '2016-05-01'}
      timelogs_data = Timelog.timelogs_for_index_view @timelogs, start_date, end_date
      @proc_timelogs = timelogs_data[:timelogs]
      @timelogs_time = timelogs_data[:time]
    end

    specify { expect(render).to have_css '.top-bar', count: 1 }
    specify { expect(render).to have_css 'form', count: 1 }
    specify { expect(render).to have_css 'tbody > tr', count: workdays }
    specify { expect(render).to have_css 'th', text: 'Minutes' }
    specify { expect(render).to have_text @timelogs.sample[:leave] }
  end
end
