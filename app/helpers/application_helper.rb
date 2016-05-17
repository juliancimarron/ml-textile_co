module ApplicationHelper

  def class_by_fullpath(class_name, request_path, class_path, path_has_more) 
    request_path = request_path.split('/').reject(&:empty?).join('/')
    class_path = class_path.split('/').reject(&:empty?).join('/')

    if path_has_more
      return class_name.to_s if request_path.start_with? class_path
    else
      return class_name.to_s if request_path == class_path
    end
  end

  def strftime_formatter(formatter, obj)
    obj.respond_to?(:strftime) ? obj.strftime(formatter) : nil
  end

  def strftime_as_date(obj) 
    strftime_formatter('%a, %d-%b-%Y', obj)
  end

  def strftime_as_time(obj) 
    strftime_formatter('%l:%M %p', obj)
  end

end
