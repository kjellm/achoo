class Achoo; end

require 'achoo/subversion'
require 'achoo/git'

class Achoo::VCS

  def self.factory(dir)
    klass = [Achoo::Git, Achoo::Subversion].find do |k|
      k.repository?(dir)
    end
    return nil if klass.nil?
    klass.new(dir)
  end

end
