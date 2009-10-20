# coding: utf-8

require 'test/helper'

class Admin::SidebarHelperTest < ActiveSupport::TestCase

  include Admin::SidebarHelper

  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper

  def setup
    default_url_options[:host] = 'test.host'
  end

  # FIXME
  def test_actions

    return

    self.expects(:default_actions).returns(['action1', 'action2'])
    self.expects(:previous_and_next).returns(['previous', 'next'])
    self.expects(:export).returns(['csv', 'pdf'])

    output = actions
    expected = <<-HTML
<h2>Actions</h2>
<ul>
<li>action1</li>
<li>action2</li>
</ul>

<h2>Go to</h2>
<ul>
<li>previous</li>
<li>next</li>
</ul>

<h2>Export</h2>
<ul>
<li>csv</li>
<li>pdf</li>
</ul>

    HTML

    assert_equal expected, output

  end

  def test_export

    @resource = { :class => Post }

    params = { :controller => 'admin/posts', :action => 'index' }
    self.expects(:params).at_least_once.returns(params)

    output = export
    expected = <<-HTML
<h2>Export</h2>
<ul>
<li><a href="http://test.host/admin/posts?format=csv">CSV</a></li>
<li><a href=\"http://test.host/admin/posts?format=xml\">XML</a></li>
</ul>
HTML

    assert_equal expected, output

  end

  def test_build_typus_list_with_empty_content_and_empty_header
    output = build_typus_list([], :header => nil)
    assert output.empty?
  end

  def test_build_typus_list_with_content_and_header
    output = build_typus_list(['item1', 'item2'], :header => "Chunky Bacon")
    assert !output.empty?
    assert_match /Chunky bacon/, output
  end

  def test_build_typus_list_with_content_without_header
    output = build_typus_list(['item1', 'item2'])
    assert !output.empty?
    assert_no_match /h2/, output
    assert_no_match /\/h2/, output
  end

  def test_previous_and_next_when_edit

    @resource = { :class => TypusUser }
    @current_user = typus_users(:admin)

    # Test when there are no records.

    typus_user = TypusUser.first
    @previous, @next = nil, nil

    params = { :controller => 'admin/typus_users', :action => 'edit', :id => typus_user.id }
    self.expects(:params).at_least_once.returns(params)

    assert previous_and_next.empty?

    # Test when we are on the first item.

    typus_user = TypusUser.first
    @previous, @next = typus_user.previous_and_next

    expected = <<-HTML
<h2>Go to</h2>
<ul>
<li><a href="http://test.host/admin/typus_users/edit/2">Next</a></li>
</ul>
    HTML
    assert_equal expected, previous_and_next

    # Test when we are on the last item.

    typus_user = TypusUser.last
    @previous, @next = typus_user.previous_and_next

    expected = <<-HTML
<h2>Go to</h2>
<ul>
<li><a href="http://test.host/admin/typus_users/edit/4">Previous</a></li>
</ul>
    HTML

    assert_equal expected, previous_and_next

    # Test when we are on the middle.

    typus_user = TypusUser.find(3)
    @previous, @next = typus_user.previous_and_next

    expected = <<-HTML
<h2>Go to</h2>
<ul>
<li><a href="http://test.host/admin/typus_users/edit/4">Next</a></li>
<li><a href="http://test.host/admin/typus_users/edit/2">Previous</a></li>
</ul>
    HTML
    assert_equal expected, previous_and_next

  end

  def test_previous_and_next_when_show

    @resource = { :class => TypusUser }
    @current_user = typus_users(:admin)

    typus_user = TypusUser.find(3)
    params = { :controller => 'admin/typus_users', :action => 'show', :id => typus_user.id }
    self.expects(:params).at_least_once.returns(params)

    @previous, @next = typus_user.previous_and_next

    output = previous_and_next
    expected = <<-HTML
<h2>Go to</h2>
<ul>
<li><a href="http://test.host/admin/typus_users/show/4">Next</a></li>
<li><a href="http://test.host/admin/typus_users/show/2">Previous</a></li>
</ul>
    HTML

    assert_equal expected, output

  end

  # FIXME
  def test_previous_and_next_with_params
    return
  end

  def test_search

    @resource = { :class => TypusUser, :self => 'typus_users' }

    params = { :controller => 'admin/typus_users', :action => 'index' }
    self.expects(:params).at_least_once.returns(params)

    output = search
    expected = <<-HTML
<h2>Search</h2>
<form action="/#{params[:controller]}" method="get">
<p><input id="search" name="search" type="text" value=""/></p>
<input id="action" name="action" type="hidden" value="index" />
<input id="controller" name="controller" type="hidden" value="admin/typus_users" />
</form>
<p class="tip">Search by first name, last name, email, and role.</p>
    HTML

    assert_equal expected, output

  end

  def test_filters

    @resource = { :class => TypusUser, :self => 'typus_users' }

    @resource[:class].expects(:typus_filters).returns(Array.new)

    output = filters
    assert output.nil?

  end

  # TODO: Test filters when @resource[:class].typus_filters returns filters.
  # 
  # Yes, I know, it's an ugly name for a test, but don't know how to 
  # name this test. Suggestions are welcome. ;)
  #
  # FIXME
  def test_filters_with_filters
    return
  end

  # FIXME
  def test_relationship_filter
    return
  end

  def test_datetime_filter

    @resource = { :class => TypusUser, :self => 'typus_users' }
    filter = 'created_at'

    params = { :controller => 'admin/typus_users', :action => 'index' }
    self.expects(:params).at_least_once.returns(params)

    request = ''
    output = datetime_filter(request, filter)
    expected = <<-HTML
<h2>Created at</h2>
<ul>
<li><a href="http://test.host/admin/typus_users?created_at=today" class="off">Today</a></li>
<li><a href="http://test.host/admin/typus_users?created_at=last_few_days" class="off">Last few days</a></li>
<li><a href="http://test.host/admin/typus_users?created_at=last_7_days" class="off">Last 7 days</a></li>
<li><a href="http://test.host/admin/typus_users?created_at=last_30_days" class="off">Last 30 days</a></li>
</ul>
    HTML
    assert_equal expected, output

    request = 'created_at=today&page=1'
    output = datetime_filter(request, filter)
    expected = <<-HTML
<h2>Created at</h2>
<ul>
<li><a href="http://test.host/admin/typus_users?created_at=today" class="on">Today</a></li>
<li><a href="http://test.host/admin/typus_users?created_at=last_few_days" class="off">Last few days</a></li>
<li><a href="http://test.host/admin/typus_users?created_at=last_7_days" class="off">Last 7 days</a></li>
<li><a href="http://test.host/admin/typus_users?created_at=last_30_days" class="off">Last 30 days</a></li>
</ul>
    HTML
    assert_equal expected, output

  end

  def test_boolean_filter

    @resource = { :class => TypusUser, :self => 'typus_users' }
    filter = 'status'

    params = { :controller => 'admin/typus_users', :action => 'index' }
    self.expects(:params).at_least_once.returns(params)

    # Status is true

    request = 'status=true&page=1'
    output = boolean_filter(request, filter)
    expected = <<-HTML
<h2>Status</h2>
<ul>
<li><a href="http://test.host/admin/typus_users?status=true" class="on">Active</a></li>
<li><a href="http://test.host/admin/typus_users?status=false" class="off">Inactive</a></li>
</ul>
    HTML
    assert_equal expected, output

    # Status is false

    request = 'status=false&page=1'
    output = boolean_filter(request, filter)
    expected = <<-HTML
<h2>Status</h2>
<ul>
<li><a href="http://test.host/admin/typus_users?status=true" class="off">Active</a></li>
<li><a href="http://test.host/admin/typus_users?status=false" class="on">Inactive</a></li>
</ul>
    HTML
    assert_equal expected, output

  end

  def test_string_filter_when_values_are_strings

    @resource = { :class => TypusUser, :self => 'typus_users' }
    filter = 'role'

    params = { :controller => 'admin/typus_users', :action => 'index' }
    self.expects(:params).at_least_once.returns(params)

    # Roles is admin

    request = 'role=admin&page=1'
    @resource[:class].expects('role').returns(['admin', 'designer', 'editor'])
    output = string_filter(request, filter)
    expected = <<-HTML
<h2>Role</h2>
<ul>
<li><a href="http://test.host/admin/typus_users?role=admin" class="on">Admin</a></li>
<li><a href="http://test.host/admin/typus_users?role=designer" class="off">Designer</a></li>
<li><a href="http://test.host/admin/typus_users?role=editor" class="off">Editor</a></li>
</ul>
    HTML
    assert_equal expected, output

    # Roles is editor

    request = 'role=editor&page=1'
    @resource[:class].expects('role').returns(['admin', 'designer', 'editor'])
    output = string_filter(request, filter)
    expected = <<-HTML
<h2>Role</h2>
<ul>
<li><a href="http://test.host/admin/typus_users?role=admin" class="off">Admin</a></li>
<li><a href="http://test.host/admin/typus_users?role=designer" class="off">Designer</a></li>
<li><a href="http://test.host/admin/typus_users?role=editor" class="on">Editor</a></li>
</ul>
    HTML
    assert_equal expected, output

  end

  def test_string_filter_when_values_are_arrays_of_strings

    @resource = { :class => TypusUser, :self => 'typus_users' }
    filter = 'role'

    params = { :controller => 'admin/typus_users', :action => 'index' }
    self.expects(:params).at_least_once.returns(params)

    request = 'role=admin&page=1'
    array = [['Administrador', 'admin'], 
             ['Diseñador', 'designer'], 
             ['Editor', 'editor']]
    @resource[:class].expects('role').returns(array)

    output = string_filter(request, filter)
    expected = <<-HTML
<h2>Role</h2>
<ul>
<li><a href="http://test.host/admin/typus_users?role=admin" class="on">Administrador</a></li>
<li><a href="http://test.host/admin/typus_users?role=designer" class="off">Diseñador</a></li>
<li><a href="http://test.host/admin/typus_users?role=editor" class="off">Editor</a></li>
</ul>
    HTML

    assert_equal expected, output

  end

  def test_string_filter_when_empty_values

    @resource = { :class => TypusUser }
    filter = 'role'

    request = 'role=admin&page=1'
    @resource[:class].expects('role').returns([])
    output = string_filter(request, filter)
    assert output.empty?

  end

end