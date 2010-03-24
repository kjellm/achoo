require 'achoo/term/table'
require 'stringio'
require 'test/unit'

class TestTermTable < Test::Unit::TestCase
  # def setup
  # end
  
  # def teardown
  # end

  def test_it
    table = Achoo::Term::Table.new(%w(a b), [%w(1 2)])
    io = StringIO.new
    table.print(io)
    expected = <<'EOT'
┌───┬───┐
│ a │ b │
├───┼───┤
│ 1 │ 2 │
└───┴───┘
EOT
    assert_equal expected, io.string


    table = Achoo::Term::Table.new(%w(a b), [])
    io = StringIO.new
    table.print(io)
    expected = <<'EOT'
┌───┬───┐
│ a │ b │
├───┼───┤
└───┴───┘
EOT
    assert_equal expected, io.string

    table = Achoo::Term::Table.new([], [])
    io = StringIO.new
    table.print(io)
    expected = <<'EOT'
┌┐
│  │
├┤
└┘
EOT
    assert_equal expected, io.string
  end

end

