require 'rails_helper'

RSpec.describe "departments/edit", type: :view do

  fixtures :departments

  let(:dept) { departments(:sales) }

  before(:example) { assign(:department, dept) }

  specify { expect(render).to have_css '#main-menu', count: 1 }
  specify{ expect(render).to have_css 'form input[type="submit"]', count: 1 }

end
