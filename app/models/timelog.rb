class Timelog < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :employee

  CLAIM_STATUS_OPT = %w(pending approved declined)


  validates :employee_id,
    presence: true,
    numericality: {
      only_integer: true,
    },
    inclusion: {      
      in: :employee_ids
    }

  validates :log_date,
    presence: true

  validate(
    :validate_arrive_datetime,
    :validate_leave_datetime,
    :validate_claim_arrive_datetime,
    :validate_claim_leave_datetime,
    :validate_claim_status
  )


  def self.process_timelogs(timesheet, employee) 
    period_minutes = 0
    processed_timelogs = []

    timelogs = Timelog.where(
      'employee_id = ? AND log_date >= ? AND log_date <= ?',
      employee.id,
      timesheet.period_start_date,
      timesheet.period_end_date
    ).order(log_date: :asc)

    timelogs.each do |timelog|
      hash = {}
      hash[:log_date] = timelog.log_date.strftime '%a, %d-%b-%Y'
      hash[:action] = {}

      arrive = timelog.arrive_datetime
      leave = timelog.leave_datetime
      if ['pending','approved'].include? timelog.claim_status
        arrive = timelog.claim_arrive_datetime unless timelog.claim_arrive_datetime.nil?
        leave = timelog.claim_leave_datetime unless timelog.claim_leave_datetime.nil?
      end
      hash[:arrive_time] = arrive.strftime '%l:%M %p'
      hash[:leave_time] = leave.strftime '%l:%M %p'

      seconds = (leave - arrive).to_i
      hash[:hours] = Util.seconds_to_hrs_min(seconds)[:hours]
      hash[:minutes] = Util.seconds_to_hrs_min(seconds)[:minutes]
      period_minutes += hash[:minutes] + hash[:hours] * 60
      
      case timelog.claim_status
      when 'pending'
        hash[:status] = 'Pending Review'
      when 'approved'
        hash[:status] = 'Claim Approved'
      when 'declined'
        hash[:status] = 'Claim Declined'
      end

      # if timesheet.pay_date - 3.days == Time.now.to_date
      if true
        link = self.new.edit_timelog_path(timelog.id)          
        case timelog.claim_status
        when NilClass
          hash[:action][:text] = 'Report Error'
          hash[:action][:path] = link
        when 'pending'
          hash[:action][:text] = 'Edit Report' 
          hash[:action][:path] = link
        end
      end
      processed_timelogs << hash
    end

    timesheet.logged_hrs = period_minutes / 60
    timesheet.logged_min = period_minutes - timesheet.logged_hrs * 60
    timesheet.save

    return processed_timelogs
  end

  private

    def employee_ids
      Employee.all.pluck(:employee_id)
    end

    def validate_arrive_datetime 
      dt_same_as_log_date(:arrive_datetime) or return
    end

    def validate_leave_datetime 
      return if leave_datetime.nil? or claim_leave_datetime

      if arrive_datetime.nil? and claim_arrive_datetime.nil?
        errors.add(:leave_datetime, "Arrive time cannot be blank if Leave time has data.")
        return
      end

      arrive = claim_arrive_datetime ? claim_arrive_datetime : arrive_datetime
      if leave_datetime < arrive
        errors.add(:leave_datetime, "The Departure cannot happen before the Arrival")
        return
      end

      dt_same_as_log_date(:leave_datetime) or return
    end

    def validate_claim_arrive_datetime 
      return if claim_arrive_datetime.nil?

      dt_same_as_log_date(:claim_arrive_datetime) or return
    end

    def validate_claim_leave_datetime 
      return if claim_leave_datetime.nil?

      dt_same_as_log_date(:claim_arrive_datetime) or return

      if arrive_datetime.nil? and claim_arrive_datetime.nil?
        errors.add(:claim_leave_datetime, "First the Arrival time has to be set.")
        return
      end

      arrive = claim_arrive_datetime ? claim_arrive_datetime : arrive_datetime
      if claim_leave_datetime < arrive
        errors.add(:claim_leave_datetime, "The Departure cannot happen before the Arrival")
        return
      end
    end

    def validate_claim_status 
      if claim_status.nil? and (claim_arrive_datetime or claim_arrive_datetime)
        errors.add(:claim_status, "A Status must be entered if there is a Claim")
        return
      end

      return if claim_status.nil?

      unless CLAIM_STATUS_OPT.include? claim_status
        errors.add(:claim_status, "The claimed status entered is invalid.")
      end    
    end

    def dt_same_as_log_date(field) 
      value = eval(field.to_s)
      return true if log_date.nil? or value.nil?

      unless value.to_date == log_date
        errors.add(field, 'The date entered is not same as the log_date')
        return false
      end

      return true
    end

end
