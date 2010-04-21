class Array

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
