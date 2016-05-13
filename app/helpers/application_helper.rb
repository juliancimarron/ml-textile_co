module ApplicationHelper

  def class_by_fullpath(class_name, request_path, class_paths) 
    request_path = request_path.split('/').reject(&:empty?).join('/')
    class_paths = [class_paths] if class_paths.class == String
    class_paths = class_paths.map{|x| x.split('/').reject(&:empty?).join('/')}
    return class_name.to_s if class_paths.any? {|x| request_path.start_with? x}
  end

  def strftime_formatter(formatter, obj)
    obj.respond_to?(:strftime) ? obj.strftime(formatter) : nil
  end

  def strftime_as_date(obj) 
    strftime_formatter('%d-%b-%Y', obj)
  end

  def strftime_as_time(obj) 
    strftime_formatter('%l:%M %p', obj)
  end

end
