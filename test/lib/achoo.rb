require 'expect'
require 'pty'

def achoo(opts)

  options = {
    :verbose => false,
  }.merge(opts)

  rc_file = File.dirname(__FILE__) << '/dot_achoo'
  cmd = 'ruby -Ilib bin/achoo --log --rcfile ' << rc_file

  PTY.spawn(cmd) do |read, write, pid|
    write.sync = true
    $expect_verbose = options[:verbose]

    yield(read, write)

  end
end
