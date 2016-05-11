require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

  describe '#class_by_fullpath' do
    it "returns passed class if request.fullpath starts with given path" do
      klass = 'big_font'
      fullpath = '/valid/path/to/resources'
      path = 'valid/path'
      res = class_by_fullpath(klass, fullpath, path)
      expect(res).to eq klass
    end

    it "returns passed class if request.fullpath starts with any of given paths" do
      klass = 'big_font'
      fullpath = '/valid/path/to/resource'
      paths = ['one/path', '/another/path/', '/valid/path/']
      res = class_by_fullpath(klass, fullpath, paths)
      expect(res).to eq klass
    end

    it "returns nil if no path matches start of request.fullpath" do
      klass = 'big_font'
      fullpath = '/valid/path/to/resource'
      paths = ['one/path', '/two/paths/', '/three/paths/']
      res = class_by_fullpath(klass, fullpath, paths)
      expect(res).to be_nil
    end
  end

end
