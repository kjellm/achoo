require 'achoo/timespan'

class Achoo; end

class Achoo::OpenTimespan < Achoo::Timespan

  def to_s
    s = super
    s.sub!(/^\([^)]+\)/, '(?+??:??)')
    s.sub!(/- .*$/, '- ?')
    s
  end
end
