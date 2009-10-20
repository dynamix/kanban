require 'test/helper'

class ActiveRecordTest < ActiveSupport::TestCase

  def test_should_verify_to_dom

    assert_equal "typus_user_new", TypusUser.new.to_dom

    typus_user = typus_users(:admin)
    assert_equal "typus_user_#{typus_user.id}", typus_user.to_dom

    assert_equal "prefix_typus_user_#{typus_user.id}", typus_user.to_dom(:prefix => 'prefix')
    assert_equal "typus_user_#{typus_user.id}_suffix", typus_user.to_dom(:suffix => 'suffix')
    assert_equal "prefix_typus_user_#{typus_user.id}_suffix", typus_user.to_dom(:prefix => 'prefix', :suffix => 'suffix')

  end

end