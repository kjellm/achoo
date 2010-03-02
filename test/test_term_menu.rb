require 'achoo/term/menu'
require 'stringio'

class Achoo
  class Term

    def self.ask(x); return "1"; end

  end
end

class TestTermMenu < Test::Unit::TestCase
  # def setup
  # end
  
  # def teardown
  # end

  def test_it
    menu    = Achoo::Term::Menu.new('', %w(a b c))
    $stdout = StringIO.new
    answer  = menu.print_ask_and_validate
    expected_menu = <<'EOT'
 1. a
 2. b
 3. c
EOT
    res = $stdout.string
    $stdout = STDOUT
    assert_equal expected_menu, res
    assert_equal "1", answer

    menu    = Achoo::Term::Menu.new('', %w())
    $stdout = StringIO.new
    answer  = menu.print_ask_and_validate
    expected_menu = ''
    res = $stdout.string
    $stdout = STDOUT
    assert_equal expected_menu, res
    assert answer.nil?

    menu    = Achoo::Term::Menu.new('', %w(a b c d e f g h i j k l), 'spec')
    $stdout = StringIO.new
    answer  = menu.print_ask_and_validate
    expected_menu = <<'EOT'
  1. a
  2. b
  3. c
  4. d
  5. e
  6. f
  7. g
  8. h
  9. i
 10. j
 11. k
 12. l
  0. spec
EOT
    res = $stdout.string
    $stdout = STDOUT
    assert_equal expected_menu, res
    assert_equal "1", answer
  end

end

