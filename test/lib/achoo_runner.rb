require 'expect'
require 'pty'
require 'test/unit'

class AchooRunner

  include Test::Unit::Assertions

  attr_accessor :reader
  attr_accessor :writer
  attr_accessor :pid

  def initialize(reader, writer, pid)
    self.reader = reader
    self.writer = writer
    self.pid    = pid
  end

  def puts(str); writer.puts str; end
  
  def expect(pattern)
    stat = reader.expect(pattern, 3)
    raise "Didn't find #{pattern} before timeout" if stat.nil?
    stat
  end

  def expect_main_prompt
    expect('[1]>')
  end
end

def achoo(opts, &block)

  options = {
    :verbose => false,
  }.merge(opts)

  rc_file = File.dirname(__FILE__) << '/dot_achoo'
  File.chmod(0600, rc_file)
  cmd = 'ruby -Ilib bin/achoo --log --rcfile ' << rc_file

  PTY.spawn(cmd) do |r, w, pid|
    w.sync = true
    $expect_verbose = options[:verbose]

    AchooRunner.new(r, w, pid).instance_eval &block

  end
end
