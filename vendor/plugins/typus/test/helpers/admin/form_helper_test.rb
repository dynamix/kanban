require 'test/helper'

class Admin::FormHelperTest < ActiveSupport::TestCase

  include Admin::FormHelper
  include Admin::MasterHelper

  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionController::UrlWriter

  # FIXME
  def test_build_form
    return
  end

  def test_typus_belongs_to_field

    params = { :controller => 'admin/post', :id => 1, :action => :create }
    self.expects(:params).at_least_once.returns(params)

    @current_user = mock()
    @current_user.expects(:can_perform?).with(Post, 'create').returns(false)
    @resource = { :class => Comment }

    expected = <<-HTML
<li><label for="item_post">Post
    <small></small>
    </label>
<select id="item_post_id" name="item[post_id]"><option value=""></option>
<option value="3">Post#3</option>
<option value="4">Post#4</option>
<option value="1">Post#1</option>
<option value="2">Post#2</option></select></li>
    HTML

    assert_equal expected, typus_belongs_to_field('post')

  end

  def test_typus_belongs_to_field_with_different_attribute_name

    default_url_options[:host] = 'test.host'

    params = { :controller => 'admin/post', :id => 1, :action => :edit }
    self.expects(:params).at_least_once.returns(params)

    @current_user = mock()
    @current_user.expects(:can_perform?).with(Comment, 'create').returns(true)
    @resource = { :class => Post }

    expected = <<-HTML
<li><label for="item_favorite_comment">Favorite comment
    <small><a href="http://test.host/admin/comments/new?back_to=%2Fadmin%2Fpost%2Fedit%2F1&selected=favorite_comment_id" onclick="return confirm('Are you sure you want to leave this page?\\n\\nIf you have made any changes to the fields without clicking the Save/Update entry button, your changes will be lost.\\n\\nClick OK to continue, or click Cancel to stay on this page.');">Add</a></small>
    </label>
<select id="item_favorite_comment_id" name="item[favorite_comment_id]"><option value=""></option>
<option value="1">John</option>
<option value="2">Me</option>
<option value="3">John</option>
<option value="4">Me</option></select></li>
    HTML
    assert_equal expected, typus_belongs_to_field('favorite_comment')

  end

  # FIXME
  def test_typus_template_field_for_boolean_fields

    return

    @resource = { :class => Post }

    expected = <<-HTML
<li><label>Test</label>
<input name="item[test]" type="hidden" value="0" /><input id="item_test" name="item[test]" type="checkbox" value="1" /> <label class=\"inline_label\" for=\"item_test\">Checked if active</label></li>
               HTML

    assert_equal expected, typus_template_field('test', 'boolean')

  end

  # FIXME
  def test_typus_template_field_for_date_fields

    return

    @resource = { :class => Post }

    expected = <<-HTML
<li><label for="item_test">Test</label>
    HTML

    assert_equal expected, typus_template_field('test', 'date')

  end

  # FIXME
  def test_typus_template_field_for_datetime_fields

    return

    @resource = { :class => Post }

    expected = <<-HTML
<li><label for="item_test">Test</label>
    HTML

    assert_equal expected, typus_template_field('test', 'datetime')

  end

  # FIXME
  def test_typus_template_field_for_file_fields

    return

    @resource = { :class => Post }
    @item = Post.new

    expected = <<-HTML
<li><label for="item_asset_file_name">Asset</label>
<input id="item_asset" name="item[asset]" size="30" type="file" />

</li>
    HTML

    assert_equal expected, typus_template_field('asset_file_name', 'file')

  end

  # FIXME
  def test_typus_template_field_for_password_fields

    return

    @resource = { :class => Post }

    expected = <<-HTML
<li><label for="item_test">Test</label>
<input class="text" id="item_test" name="item[test]" size="30" type="password" /></li>
    HTML

    assert_equal expected, typus_template_field('test', 'password')

  end

  # FIXME
  def test_typus_template_field_for_selector_fields

    return

    @resource = { :class => Post }
    @item = posts(:published)

    expected = <<-HTML
<li><label for="item_status">Status</label>
<select id="item_status"  name="item[status]">
<option value=""></option>
<option selected value="true">true</option>
<option  value="false">false</option>
<option  value="pending">pending</option>
<option  value="published">published</option>
<option  value="unpublished">unpublished</option>
</select></li>
    HTML

    assert_equal expected, typus_template_field('test', 'selector')

  end

  # FIXME
  def test_typus_template_field_for_text_fields

    return

    @resource = { :class => Post }

    expected = <<-HTML
<li><label for="item_test">Test</label>
<textarea class="text" cols="40" id="item_test" name="item[test]" rows="10"></textarea></li>
    HTML

    assert_equal expected, typus_template_field('test', 'text')

  end

  # FIXME
  def test_typus_template_field_for_time_fields

    return

    @resource = { :class => Post }

    expected = <<-HTML
<li><label for="item_test">Test</label>
    HTML

    assert_equal expected, typus_template_field('test', 'time')

  end

  def test_typus_tree_field

    return if !defined?(ActiveRecord::Acts::Tree)

    self.stubs(:expand_tree_into_select_field).returns('expand_tree_into_select_field')

    @resource = { :class => Page }
    items = @resource[:class].roots

    expected = <<-HTML
<li><label for="item_parent">Parent</label>
<select id="item_parent"  name="item[parent]">
  <option value=""></option>
  expand_tree_into_select_field
</select></li>
    HTML

    assert_equal expected, typus_tree_field('parent', items)

  end

  # FIXME
  def test_typus_string_field

    return

    @resource = { :class => Post }

    expected = <<-HTML
<li><label for="item_test">Test</label>
<input class="text" id="item_test" name="item[test]" size="30" type="text" /></li>
    HTML

    assert_equal expected, typus_template_field('test', 'string')

  end

  # FIXME
  def test_typus_relationships
    return
  end

  # FIXME
  def test_typus_form_has_many_with_items

    return

    @current_user = typus_users(:admin)
    @resource = { :class => Post, :self => 'posts' }
    @item = Post.find(1)

    params = { :controller => 'admin/posts', :id => 1, :action => 'edit' }
    self.expects(:params).at_least_once.returns(params)

    self.stubs(:build_list).returns('<!-- a_nice_list -->')

    output = typus_form_has_many('comments')
    expected = <<-HTML
<a name="comments"></a>
<div class="box_relationships">
  <h2>
  <a href="http://test.host/admin/comments" title="Comments filtered by Post#1">Comments</a>
  <small><a href="http://test.host/admin/comments/new?back_to=%23comments&resource=post&resource_id=1">Add new</a></small>
  </h2>
<!-- a_nice_list --></div>
    HTML

    assert_equal expected, output

  end

  # FIXME
  def test_typus_form_has_many_without_items

    return

    @current_user = typus_users(:admin)
    @resource = { :class => Post, :self => 'posts' }
    @item = Post.find(1)
    @item.comments.destroy_all

    params = { :controller => 'admin/posts', :id => 1, :action => 'edit' }
    self.expects(:params).at_least_once.returns(params)

    output = typus_form_has_many('comments')
    expected = <<-HTML
<a name="comments"></a>
<div class="box_relationships">
  <h2>
  <a href="http://test.host/admin/comments" title="Comments filtered by Post#1">Comments</a>
  <small><a href="http://test.host/admin/comments/new?back_to=%23comments&resource=post&resource_id=1">Add new</a></small>
  </h2>
  <div id="flash" class="notice"><p>There are no comments.</p></div>
</div>
    HTML

    assert_equal expected, output

  end

  # FIXME
  def test_typus_form_has_and_belongs_to_many
    return
  end

  # FIXME
  def test_typus_template_field
    return
  end

  def test_attribute_disabled

    @resource = { :class => Post }

    assert !attribute_disabled?('test')

    Post.expects(:accessible_attributes).returns(['test'])
    assert !attribute_disabled?('test')

    Post.expects(:accessible_attributes).returns(['no_test'])
    assert attribute_disabled?('test')

  end

  def test_expand_tree_into_select_field

    return if !defined?(ActiveRecord::Acts::Tree)

    items = Page.roots

    # Page#1 is a root.

    @item = Page.find(1)
    output = expand_tree_into_select_field(items, 'parent_id')
    expected = <<-HTML
<option  value="1"> &#92;_ Page#1</option>
<option  value="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &#92;_ Page#2</option>
<option  value="3"> &#92;_ Page#3</option>
<option  value="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &#92;_ Page#4</option>
<option  value="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &#92;_ Page#5</option>
<option  value="6">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &#92;_ Page#6</option>
    HTML
    assert_equal expected, output

    # Page#4 is a children.

    @item = Page.find(4)
    output = expand_tree_into_select_field(items, 'parent_id')
    expected = <<-HTML
<option  value="1"> &#92;_ Page#1</option>
<option  value="2">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &#92;_ Page#2</option>
<option selected value="3"> &#92;_ Page#3</option>
<option  value="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &#92;_ Page#4</option>
<option  value="5">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &#92;_ Page#5</option>
<option  value="6">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &#92;_ Page#6</option>
    HTML
    assert_equal expected, output

  end

end