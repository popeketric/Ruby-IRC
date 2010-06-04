require 'test/unit'
require 'IRCUtil'

class TestIRCUtil < Test::Unit::TestCase
    def test_quote_regexp
        assert_equal("^.*\\.example\\.com$", IRCUtil.quote_regexp_for_mask("*.example.com"))
    end

    def test_assert_hostmask
        assert(IRCUtil.assert_hostmask("bar.example.com", "ba*.example.com"))
        assert(IRCUtil.assert_hostmask("bar.example.com", "bar.example.com"))
        assert(IRCUtil.assert_hostmask("bar.example.com", "*.example.com"))
        assert(IRCUtil.assert_hostmask("bar.example.com", "*r.example.com"))
        assert(! IRCUtil.assert_hostmask("bar.example.com", "c*.example.com"))
        assert(! IRCUtil.assert_hostmask("bar.example.com", "*.*.net"))
    end
end
