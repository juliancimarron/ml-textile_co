class Util

  def self.seconds_to_hrs_min(seconds) 
    minutes = seconds / 60
    minutes += 1 if seconds > minutes * 60
    hours = minutes / 60
    minutes = minutes - hours * 60
    return {hours: hours, minutes: minutes}
  end

end
