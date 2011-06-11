# encoding: utf-8

require 'achoo/term/table'
require 'test_helpers'

class TestTermTable < Test::Unit::TestCase
  # def setup
  # end
  
  # def teardown
  # end

  def test_data_and_header
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
  end

  def test_no_data
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
  end

  def test_empty
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

