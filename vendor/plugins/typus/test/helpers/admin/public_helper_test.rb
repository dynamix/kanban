require 'test/helper'

class Admin::PublicHelperTest < ActiveSupport::TestCase

  include Admin::PublicHelper

  def test_quick_edit

    options = { :path => 'articles/edit/1', :message => 'Edit this article' }
    output = quick_edit(options)

    html = <<-HTML
<script type="text/javascript">
  document.write('<script type="text/javascript" src="quick_edit?message=Edit+this+article&path=articles%2Fedit%2F1" />');
</script>
    HTML

    assert_equal html, output

  end

  def admin_quick_edit_path
    'quick_edit'
  end

end