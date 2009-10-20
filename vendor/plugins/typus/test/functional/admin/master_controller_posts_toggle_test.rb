require 'test/helper'

class Admin::PostsControllerTest < ActionController::TestCase

  def test_should_toggle_an_item

    @request.env['HTTP_REFERER'] = '/admin/posts'

    post = posts(:unpublished)
    get :toggle, { :id => post.id, :field => 'status' }

    assert_response :redirect
    assert_redirected_to @request.env['HTTP_REFERER']
    assert_equal "Post status changed.", flash[:success]
    assert Post.find(post.id).status

  end

  def test_should_not_toggle_an_item_when_disabled

    @request.env['HTTP_REFERER'] = '/admin/posts'

    options = Typus::Configuration.options.merge(:toggle => false)
    Typus::Configuration.stubs(:options).returns(options)

    post = posts(:unpublished)
    get :toggle, { :id => post.id, :field => 'status' }

    assert_response :redirect
    assert_redirected_to @request.env['HTTP_REFERER']
    assert_equal "Toggle is disabled.", flash[:notice]

  end

end