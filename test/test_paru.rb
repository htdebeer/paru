require "minitest/autorun"

require_relative "../lib/paru"

class ParuTest < MiniTest::Test

    def setup
    end

    def test_info
      info = Paru::Pandoc.info
      assert_match(/\d+\.\d+/, info[:version])
      assert_match(/\.pandoc$/, info[:data_dir])
    end
    
end
