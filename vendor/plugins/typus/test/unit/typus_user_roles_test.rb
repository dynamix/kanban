require 'test/helper'

class TypusUserRolesTest < ActiveSupport::TestCase

  def test_should_get_list_of_roles
    roles = %w( admin designer editor )
    assert_equal roles, Typus::Configuration.roles.map(&:first).sort
  end

  def test_admin_role_settings

    typus_user = typus_users(:admin)
    assert_equal 'admin', typus_user.role

    models = %w( Asset Category Comment Delayed::Task Git Page Post Status TypusUser View WatchDog )
    assert_equal models, typus_user.resources.map(&:first).sort

    # Order exists on the roles, but, as we compact the hash, the
    # resource is removed.
    assert !typus_user.resources.map(&:first).include?('Order')

    resources = %w( Git Status WatchDog )
    models.delete_if { |m| resources.include?(m) }

    %w( create read update destroy ).each do |action|
      models.each { |model| assert typus_user.can_perform?(model, action) }
    end

    # Order resource doesn't have an index action, so we current user 
    # cannot perform the action.
    assert !typus_user.can_perform?('Order', 'index')

    # Status resource has an index action, but not a show one.
    # We add the { :special => true } option to by-pass the action 
    # renaming performed in the TypusUser#can_perform? method.
    assert typus_user.can_perform?('Status', 'index', { :special => true })
    assert !typus_user.can_perform?('Status', 'show', { :special => true })

  end

  def test_editor_role_settings

    typus_user = typus_users(:editor)
    assert_equal 'editor', typus_user.role

    %w( Category Comment Git Post TypusUser ).each do |model|
      assert typus_user.resources.map(&:first).include?(model)
    end

    # Category: create, read, update
    %w( create read update ).each { |action| assert typus_user.can_perform?('Category', action) }
    %w( delete ).each { |action| assert !typus_user.can_perform?('Category', action) }

    # Post: create, read, update
    %w( create read update ).each { |action| assert typus_user.can_perform?('Post', action) }
    %w( delete ).each { |action| assert !typus_user.can_perform?('Post', action) }

    # Comment: read, update, delete
    %w( read update delete ).each { |action| assert typus_user.can_perform?('Comment', action) }
    %w( create ).each { |action| assert !typus_user.can_perform?('Comment', action) }

    # TypusUser: read, update
    %w( read update ).each { |action| assert typus_user.can_perform?('TypusUser', action) }
    %w( create delete ).each { |action| assert !typus_user.can_perform?('TypusUser', action) }

  end

  def test_designer_role_settings

    typus_user = typus_users(:designer)
    assert_equal 'designer', typus_user.role

    models = %w( Category Comment Post )
    assert_equal models, typus_user.resources.map(&:first).sort

    # Category: read, update
    %w( read update ).each { |action| assert typus_user.can_perform?('Category', action) }
    %w( create delete ).each { |action| assert !typus_user.can_perform?('Category', action) }

    # Comment: read
    %w( read ).each { |action| assert typus_user.can_perform?('Comment', action) }
    %w( create update delete ).each { |action| assert !typus_user.can_perform?('Comment', action) }

    # Post: read, update
    %w( read update ).each { |action| assert typus_user.can_perform?('Post', action) }
    %w( create delete ).each { |action| assert !typus_user.can_perform?('Post', action) }

  end

end