class Timelog < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :employee

  CLAIM_STATUS_OPT = %w(pending approved declined)
  REPORT_TYPE_OPT = {tardies: 'Tardies', missed_work: 'Missed Work'}


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
    :validate_arrive_sec,
    :validate_leave_sec,
    :validate_claim_leave_sec,
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

      arrive = get_correct_moment(:arrive, timelog)
      leave = get_correct_moment(:leave, timelog)
      hash[:arrive_time] = arrive ? arrive.strftime('%l:%M %p') : 'Missing'
      hash[:leave_time] = leave ? leave.strftime('%l:%M %p') : 'Missing'

      seconds = (leave.nil? or arrive.nil?) ? 0 : (leave - arrive).to_i
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

    def validate_arrive_sec 
      return if arrive_sec.nil?

      if arrive_sec > max_sec_in_day()
        errors.add(:arrive_sec, "The time entered is beyond an acceptable range.")
        return
      end
    end

    def validate_leave_sec 
      return if leave_sec.nil? or claim_leave_sec

      if leave_sec > max_sec_in_day()
        errors.add(:leave_sec, "The time entered is beyond an acceptable range.")
        return
      end

      if arrive_sec.nil? and claim_arrive_sec.nil?
        errors.add(:leave_sec, "Arrive time cannot be blank if Leave time has data.")
        return
      end

      arrive = claim_arrive_sec ? claim_arrive_sec : arrive_sec
      if leave_sec < arrive
        errors.add(:leave_sec, "The Departure cannot happen before the Arrival")
        return
      end
    end

    def validate_claim_leave_sec 
      return if claim_leave_sec.nil?

      if arrive_sec.nil? and claim_arrive_sec.nil?
        errors.add(:claim_leave_sec, "Arrive time cannot be blank if Leave time has data.")
        return
      end

      arrive = claim_arrive_sec ? claim_arrive_sec : arrive_sec
      if claim_leave_sec < arrive
        errors.add(:claim_leave_sec, "The Departure cannot happen before the Arrival")
        return
      end
    end

    def max_sec_in_day 
      24.hours - 1.second
    end

    def validate_claim_status 
      if claim_status.nil? and (claim_arrive_sec or claim_arrive_sec)
        errors.add(:claim_status, "A Status must be entered if there is a Claim")
        return
      end

      return if claim_status.nil?

      unless CLAIM_STATUS_OPT.include? claim_status
        errors.add(:claim_status, "The claimed status entered is invalid.")
      end    
    end

    def self.get_correct_moment(moment, timelog) 
      time_col = "#{moment}_sec".to_sym
      claim_time_col = "claim_#{moment}_sec".to_sym
      time_recorded = timelog.send(time_col)
      time_claim = timelog.send(claim_time_col)
      status = timelog.send :claim_status

      res = time_claim ? time_claim : time_recorded
      res = time_recorded if status == 'declined'
      return res
    end

end
