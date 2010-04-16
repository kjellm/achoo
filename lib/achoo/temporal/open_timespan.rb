require 'achoo/temporal'

class Achoo::Temporal::OpenTimespan < Achoo::Temporal::Timespan

  def to_s
    s = super
    s.sub!(/^\([^)]+\)/, '(?+??:??)')
    s.sub!(/- .*$/, '- ?')
    s
  end
end
