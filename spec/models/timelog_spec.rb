require 'rails_helper'
require 'support/model_attributes'
require 'support/shared_context'

RSpec.describe Timelog, type: :model do
  include_context 'model_attributes'
  include_context 'create_timelogs'

  fixtures :timelogs
  fixtures :employees

  let(:valid_timelog) { Timelog.new timelog_valid_attributes }
  let(:reg_employee) { employees(:john) }
  let(:admin_employee) { employees(:julian) }

  shared_examples 'less_than_sec_in_day' do |field|
    it "the number of seconds entered is beyond 1 day" do
      timelog = valid_timelog
      timelog[field] = 25.hours
      expect(timelog).to be_invalid
    end
  end

  describe 'employee_id' do
    context 'valid attributes' do 
      it "is a valid id" do
        timelog = valid_timelog
        timelog.employee_id = Employee.first.id
        expect(timelog).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "is an invalid id" do
        timelog = valid_timelog
        timelog.employee_id = 999
        expect(timelog).to be_invalid
      end

      it "is blank" do
        timelog = valid_timelog
        timelog.employee_id = ''
        expect(timelog).to be_invalid
      end
    end
  end

  describe 'log_date' do
    context 'valid attributes' do 
      it "is an object that responds to :to_date" do
        timelog = valid_timelog
        timelog.log_date = DateTime.now + 2.days
        expect(timelog).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "is blank" do
        timelog = valid_timelog
        timelog.log_date = ''
        expect(timelog).to be_invalid
      end

      it "cannot create duplicate combinations of employee_id and log_date" do
        a = timelogs(:john).attributes
        timelog = Timelog.new(
          employee_id: a[:employee_id], 
          log_date: a[:log_date], 
          arrive_sec: a[:arrive_sec]
        )
        expect(timelog).to be_invalid
      end
    end
  end

  describe 'arrive_sec' do
    context 'invalid attributes' do 
      it_behaves_like 'less_than_sec_in_day', :arrive_sec
    end
  end

  describe 'leave_sec' do
    context 'valid attributes' do
      it "skips tests if claim_leave_sec has a value" do
        timelog = valid_timelog
        timelog.leave_sec = nil
        expect(timelog).to be_valid
      end
    end

    context 'invalid attributes' do 
      let(:test_timelog) do
        timelog = valid_timelog
        timelog.claim_leave_sec = nil # so these tests can run
        return timelog
      end

      it_behaves_like 'less_than_sec_in_day', :arrive_sec

      it "has leave_sec but arrive_sec = nil, claim_arrive_sec = nil" do
        timelog = test_timelog
        timelog.arrive_sec = nil
        timelog.claim_arrive_sec = nil
        timelog.leave_sec = 17.hours
        expect(timelog).to be_invalid
      end

      it "rejects leave_sec < arrive_sec if claim_arrive_sec = nil" do
        timelog = test_timelog
        timelog.claim_arrive_sec = nil
        timelog.arrive_sec = 8.hours
        timelog.leave_sec = timelog.arrive_sec - 3.hours
        expect(timelog).to be_invalid
      end

      it "rejects leave_sec < claim_arrive_sec if arrive_sec = nil" do
        timelog = test_timelog
        timelog.arrive_sec = nil
        timelog.claim_arrive_sec = 8.hours
        timelog.leave_sec = timelog.claim_arrive_sec - 3.hours
        expect(timelog).to be_invalid
      end

      it "rejects leave_sec < claim_arrive_sec if both arrive_sec and claim_arrive_sec" do
        timelog = test_timelog
        timelog.arrive_sec = 9.hours  # this would be valid
        timelog.claim_arrive_sec = 18.hours
        timelog.leave_sec = 17.hours # this is invalid
        expect(timelog).to be_invalid
      end
    end
  end

  describe 'claim_arrive_sec' do
    context 'invalid attributes' do 
      it_behaves_like 'less_than_sec_in_day', :claim_arrive_sec
    end
  end

  describe 'claim_leave_sec' do
    context 'invalid attributes' do 
      it_behaves_like 'less_than_sec_in_day', :arrive_sec

      it "has claim_leave_sec but arrive_sec and claim_arrive_sec are nil" do
        timelog = valid_timelog
        timelog.claim_leave_sec = 18.hours
        timelog.arrive_sec = nil
        timelog.claim_arrive_sec = nil        
        expect(timelog).to be_invalid
      end

      it "rejects claim_leave_sec < arrive_sec if claim_arrive_sec = nil" do
        timelog = valid_timelog
        timelog.claim_arrive_sec = nil
        timelog.arrive_sec = 8.hours
        timelog.claim_leave_sec = timelog.arrive_sec - 3.hours
        expect(timelog).to be_invalid
      end

      it "rejects claim_leave_sec < claim_arrive_sec if arrive_sec = nil" do
        timelog = valid_timelog
        timelog.arrive_sec = nil
        timelog.claim_arrive_sec = 9.hours
        timelog.claim_leave_sec = timelog.claim_arrive_sec - 3.hours
        expect(timelog).to be_invalid
      end

      it "rejects claim_leave_sec < claim_arrive_sec if both arrive_sec and claim_arrive_sec" do
        timelog = valid_timelog
        timelog.arrive_sec = 9.hours # this would be valid
        timelog.claim_arrive_sec = 18.hours
        timelog.claim_leave_sec = 17.hours # this is invalid
        expect(timelog).to be_invalid
      end
    end
  end

  describe 'claim_status' do
    context 'valid attributes' do 
      it "receives a valid entry" do
        timelog = valid_timelog
        timelog.claim_status = Timelog::CLAIM_STATUS_OPT.first
        expect(timelog).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "is blank if there is claim data" do
        timelog = valid_timelog
        timelog.claim_arrive_sec = 9.hours
        timelog.claim_status = nil
        expect(timelog).to be_invalid
      end

      it "receives an invalid options" do
        timelog = valid_timelog
        timelog.claim_status = 'invalid_entry'
        expect(timelog).to be_invalid
      end
    end
  end

  describe '.get_correct_moment' do
      it "returns claim if status = pending" do
        timelog = valid_timelog
        timelog.claim_status = 'pending'
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.claim_arrive_sec
      end

      it "returns claim if status = approved" do
        timelog = valid_timelog
        timelog.claim_status = 'approved'
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.claim_arrive_sec
      end

      it "returns recorded if status = declined" do
        timelog = valid_timelog
        timelog.claim_status = 'declined'
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.arrive_sec
      end

      it "returns recorded if status = nil and claim = nil" do
        timelog = valid_timelog
        timelog.claim_status = nil
        timelog.claim_arrive_sec = nil
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.arrive_sec
      end

      it "returns claim if status = nil and recorded = nil" do
        timelog = valid_timelog
        timelog.claim_status = nil
        timelog.arrive_sec = nil
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.claim_arrive_sec
      end
  end

  describe '.timelogs_for_index_view' do
    let(:john_timelogs_relation) { Timelog.where(id: timelogs(:john).id) }

    describe "returns a structured hash with all pertinent information" do
      let(:proc_timelogs) do
        Timelog.timelogs_for_index_view(
          john_timelogs_relation, 
          john_timelogs_relation.first.log_date, 
          john_timelogs_relation.first.log_date)
      end

      specify { expect(proc_timelogs).to be_a Hash }
      specify { expect(proc_timelogs[:timelogs]).to be_an Array }
      specify { expect(proc_timelogs[:timelogs].first).to be_a Hash }
      specify { expect(proc_timelogs[:timelogs].first.empty?).to be false }
      specify { expect(proc_timelogs[:time]).to be_a Hash }
      specify { expect(proc_timelogs[:time][:hours]).to be_a Fixnum }
      specify { expect(proc_timelogs[:time][:minutes]).to be_a Fixnum }
    end

    it "processes all timelogs within the data range" do
      start_date = Date.new 2016,5,16 # Monday
      end_date = start_date + 8.days # Tuesday of next week
      no_of_business_days = 7

      Timelog.delete_all
      test_timelogs = create_timelogs(start_date, end_date, reg_employee, false)
      test_timelogs = Timelog.where id: test_timelogs.map(&:id) # to an ActiveRecord relation
      proc_timelogs = Timelog.timelogs_for_index_view(test_timelogs, start_date, end_date)

      expect(proc_timelogs[:timelogs].count).to eq no_of_business_days
    end

    it "if a timelog is found for a given business day it includes all required attributes" do
      attributes = %i(log_date arrive_time leave_time hours minutes)
      proc_timelogs = Timelog.timelogs_for_index_view(
        john_timelogs_relation, john_timelogs_relation.first.log_date, john_timelogs_relation.first.log_date)
      for attribute in attributes
        expect(proc_timelogs[:timelogs].first.key? attribute).to be true
      end
    end

    it "if a timelog is not found for a given business day it includes all required attributes" do
      attributes = %i(log_date arrive_time leave_time status)
      proc_timelogs = Timelog.timelogs_for_index_view(
        john_timelogs_relation, Date.new(2016,5,16), Date.new(2016,5,16))
      for attribute in attributes
        expect(proc_timelogs[:timelogs].first.key? attribute).to be true
      end
    end

    context 'action links' do 
      let(:test_timelogs) do
        last_month = Time.now - 1.month
        last_month = Date.new last_month.year, last_month.month
        last_month += 1.day while last_month.cwday != 1 # make it start on a Monday
        create_timelogs(last_month, last_month, reg_employee, false)
        Timelog.all.each do |t|
          t.claim_arrive_sec = nil
          t.claim_leave_sec = nil
          t.claim_status = nil
          t.save
        end
        Timelog.all
      end

      context "it's review day for previous period's timelogs" do 
        let(:review_days) { 3 }

        before(:each) do
          Timelog.delete_all
          new_payroll = {pay_day: (Time.now.to_date + review_days).day, review_days_before_pay_day: review_days}
          stub_const('Timelog::PAYROLL', new_payroll)
        end

        it "link Report Error if claim_status = nil" do
          proc_timelogs = Timelog.timelogs_for_index_view(
            test_timelogs, test_timelogs.first.log_date, test_timelogs.first.log_date)
          expect(proc_timelogs[:timelogs].first[:action][:text])
            .to be_a String
          expect(proc_timelogs[:timelogs].first[:action][:path])
            .to eq edit_timelog_path(Timelog.first.id)
        end

        it "link Edit Report if claim_status = pending" do
          test_timelogs.first.claim_arrive_sec = 9.hours
          test_timelogs.first.claim_status = 'pending'
          proc_timelogs = Timelog.timelogs_for_index_view(
            test_timelogs, test_timelogs.first.log_date, test_timelogs.first.log_date)
          expect(proc_timelogs[:timelogs].first[:action][:text])
            .to be_a String
          expect(proc_timelogs[:timelogs].first[:action][:path])
            .to eq edit_timelog_path(Timelog.first.id)
        end
      end
        
      context 'outside the review date' do 
        it "doesn't return anything" do
          timelogs = Timelog.where(id: timelogs(:john))
          timelogs.first.claim_arrive_sec = 9.hours
          timelogs.first.claim_status = 'pending'
          proc_timelogs = Timelog.timelogs_for_index_view(
            timelogs, timelogs.first.log_date, timelogs.first.log_date)
          expect(proc_timelogs[:timelogs].first.key? :action).to be false
        end
      end
    end
  end
end
