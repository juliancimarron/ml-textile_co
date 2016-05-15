require 'rails_helper'

RSpec.describe TimelogsHelper, type: :helper do

  fixtures :employees

  describe '#print_late_by' do
    let(:today) { DateTime.new 2016,5,1 }
    let(:scheduled_arrive_time) { 9.hours }

    it "returns time difference if arrive_datetime > scheduled" do
      late_by = 35.minutes
      timelog = Timelog.new(
        employee: employees(:john),
        log_date: today,
        arrive_datetime: today + scheduled_arrive_time + late_by
      )
      expect(print_late_by(scheduled_arrive_time, timelog)).to eq "#{late_by / 60} minutes"
    end

    it "returns time difference if claim_arrive_datetime > scheduled and claim_status = pending" do
      late_by = 35.minutes
      timelog = Timelog.new(
        employee: employees(:john),
        log_date: today,
        claim_arrive_datetime: (today + scheduled_arrive_time + late_by),
        claim_status: 'pending'
      )
      expect(print_late_by(scheduled_arrive_time, timelog)).to eq "#{late_by / 60} minutes"
    end

    it "returns time difference if arrive_datetime > scheduled and claim_status = declined" do
      late_by = 35.minutes
      timelog = Timelog.new(
        employee: employees(:john),
        log_date: today,
        arrive_datetime: (today + scheduled_arrive_time + late_by),
        claim_arrive_datetime: (today + scheduled_arrive_time + late_by + 2.hours),
        claim_status: 'declined'
      )
      expect(print_late_by(scheduled_arrive_time, timelog)).to eq "#{late_by / 60} minutes"
    end

    it "returns 'N/A' if arrive_datetime.nil? and claim_arrive_datetime.nil?" do
      late_by = 35.minutes
      timelog = Timelog.new(
        employee: employees(:john),
        log_date: today,
      )
      expect(print_late_by(scheduled_arrive_time, timelog)).to eq "N/A"
    end
  end

end
