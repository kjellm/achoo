class Array

  %w(merge!).each do |method|
    raise "Method already defined: #{name}\##{method}" \
      if method_defined?(method)
  end

  #
  # Useful for merging two sorted arrays with Comparable elements.
  #
  # The content of the two input arrays should not be trusted after
  # being mistreated by this method.
  # 
  def merge!(other)
    # FIX raise exception if merge is defined?
    array = []
    until empty? or other.empty?
      if first <= other.first
        array << shift
      else
        array << other.shift
      end
    end
    array.concat(self).concat(other)
    array
  end

end


class Integer

  %w(day days hour hours minute minutes).each do |method|
    raise "Method already defined: #{name}\##{method}" \
      if method_defined?(method)
  end
    
  def day; self * 86400; end
  alias days day

  def hour; self * 3600; end
  alias hours hour

  def minute; self * 60; end
  alias minutes minute

end
