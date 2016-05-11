require 'rails_helper'

RSpec.describe "_top_menu", type: :view do

  specify { expect(render).to have_css '.top-bar', count: 1 }
  specify { expect(render).to have_css '.top-bar-title', text: 'Textile.Co' }
  specify { expect(render).to have_css '#responsive-menu', count: 1}

end
