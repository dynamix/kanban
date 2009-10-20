require 'test/helper'

class HashTest < ActiveSupport::TestCase

  def test_should_verify_compact
    hash = { 'a' => '', 'b'=> nil, 'c' => 'hello' }
    hash_compacted = { 'c' => 'hello' }
    assert_equal hash_compacted, hash.compact
  end

end