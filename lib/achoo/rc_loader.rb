class Achoo; end

module Achoo::RCLoader

  RC_FILE = "#{ENV['HOME']}/.achoo"

  def load_rc
    #create_empty_rc_if_not_exists
    file_permissions_secure?

    load RC_FILE

    verify_rc_contents
  end

  private

  def file_permissions_secure?
    # FIX test to is to strict
    if File.stat(RC_FILE).mode != 0100600
      warn "Insecure permissions on #{RC_FILE}"
      exit 1
    end
  end

  def create_empty_rc_if_not_exists
    return if FileTest.exist?(RC_FILE)

    FileUtils.touch(RC_FILE)
    FileUtils.chmod(0600, RC_FILE)
  end

  def verify_rc_contents
    unless Object.const_defined?('RC')
      warn "Malformed run control file: No RC constant defined"
      exit 1
    end

    %w(url user password).each do |key|
      unless RC.has_key?(key.to_sym)
        warn "Missing mandatory run control configuration variable: #{key}"
        exit 1
      end
    end

    %w(vcs_dirs ical).each do |key|
      unless RC.has_key?(key.to_sym)
        warn "Missing run control configuration variable: #{key}. " \
             + "Add it to #{RC_FILE} to get rid of this warning"
        RC[key] = []
      end
    end
  end

end
