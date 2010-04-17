
class Array

  # FIX raise exception if merge is defined?

  #
  # Useful for merging two sorted arrays
  # 
  def merge(other)
    array = []
    until empty? or other.empty?
      if yield(first, other.first)
        array << shift
      else
        array << other.shift
      end
    end
    array.concat(self).concat(other)
    array
  end

end
