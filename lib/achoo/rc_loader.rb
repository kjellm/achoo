class Achoo; end

module Achoo::RCLoader

  def load_rc
    rc_file = "#{ENV['HOME']}/.achoo"

    # FIX test
    if File.stat(rc_file).mode != 0100600
      warn "Insecure permissions on #{rc_file}"
      exit 1
    end

    load rc_file
  end

end
