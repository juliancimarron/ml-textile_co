require 'rails_helper'

RSpec.describe "lib/util.rb" do

  describe '.seconds_to_hrs_min' do
    it "turns full-minute seconds to hours and minutes hash" do
      res = Util.seconds_to_hrs_min(48.hours + 15.minutes)
      expect(res[:hours]).to eq 48
      expect(res[:minutes]).to eq 15
    end

    it "rounds non-full-minute seconds to the next minute" do
      res = Util.seconds_to_hrs_min(48.hours + 15.minutes + 1.second)
      expect(res[:minutes]).to eq 16
    end
  end

end
