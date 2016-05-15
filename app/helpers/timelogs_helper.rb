module TimelogsHelper

  def print_late_by(arrive_time, timelog) 
    correct_arrive = timelog.log_date + arrive_time
    res = 'N/A'

    if arrive = Timelog.get_correct_moment(:arrive, timelog)
      sec_diff = arrive ? (arrive - correct_arrive).to_i : 0
      res = sec_diff > 0 ? "#{sec_diff / 60} minutes" : nil
    end

    return res
  end

end
