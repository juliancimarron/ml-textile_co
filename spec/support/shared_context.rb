RSpec.shared_context 'create_timelogs' do

  def dist_rand(values, distr, has_sign)
    return unless values.size == distr.size
    r = rand(0..99)
    value_index = distr.index {|x| x > r}
    value = values[value_index]
    return has_sign ? [1,-1].sample * value : value
  end

  def create_timelogs(date_start, date_end, employee) 
    d_values = [0, rand(1..30).minutes]
    d_weights = [90, 100]
    ActiveRecord::Base.transaction do
      date = date_start - 1.day
      while date <= date_end
        next if dist_rand([false,true], [95,100], false)
        date += 1.day
        next if [6,7].include? date.cwday  # skip Weekends
        Timelog.create(
          employee_id: employee.id,
          log_date: date,
          arrive_sec: 9.hours + dist_rand(d_values, d_weights, true).seconds,
          leave_sec: 18.hours + dist_rand(d_values, d_weights, true).seconds
        )
      end
    end
  end

  def create_timesheets(range_start_date, range_end_date, employee) 
    start_date = range_start_date
    end_date = Date.new(range_start_date.year, range_start_date.month, -1)
    while start_date <= range_end_date
      seconds = Timelog.where(
        'employee_id = ? AND log_date >= ? AND log_date <= ?',
        employee.id, start_date, end_date
      ).map{|timelog| 
        arrive = Timelog.get_correct_moment(:arrive, timelog)
        leave = Timelog.get_correct_moment(:arrive, timelog)
        return (leave.nil? or arrive.nil?) ? 0 : leave - arrive
      }.inject(:+).to_i

      Timesheet.create(
        employee: employee,
        period_start_date: start_date,
        period_end_date: end_date,
        logged_hrs: Util.seconds_to_hrs_min(seconds)[:hours],
        logged_min: Util.seconds_to_hrs_min(seconds)[:minutes],
        pay_date: end_date + 7.days
      )
    end
    start_date = Date.new(start_date.year, start_date.month + 1, 1)
    end_date = Date.new(start_date.year, start_date.month, -1)
  end

  def month_workdays(year, month) 
    date = Date.new(year, month) - 1.day
    workdays = 0
    while date.month <= month
      date += 1.day
      next if [6,0].include? date.wday
      workdays += 1
    end
    return workdays
  end


end
