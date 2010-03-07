require 'achoo/term'

class Achoo; class UI; end; end

class Achoo::UI::MonthChooser

  def choose
    default = one_month_ago
    period  = Achoo::Term::ask "Period ([#{default}] | YYYYMM)"
    period  = default if !period || period.empty?
    # FIX validate YYYYMM
    period
  end

  def one_month_ago
    now   = Time.now
    year  = now.year

    # Use -2 + 1 to shift range from 0-11 to 1-12 
    month = (now.month - 2)%12 + 1
    year -= 1 if month > now.month

    sprintf "%d%02d", year, month
  end

end    

