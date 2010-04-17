require 'achoo'
require 'achoo/term'
require 'yaml'

module Achoo::RCLoader

  def load_rc(rc_file="#{ENV['HOME']}/.achoo")
    #create_empty_rc_if_not_exists(rc_file)
    file_permissions_secure?(rc_file)

    self.class.const_set(:RC, YAML.load_file(rc_file))
    if RC.is_a? String
      abort "Failed to parse rc file. Do you use the old format? Please convert it to YAML."
    end

    verify_rc_contents(rc_file)
  end

  private

  def file_permissions_secure?(rc_file)
    # FIX test to is to strict
    if File.stat(rc_file).mode != 0100600
      puts Achoo::Term.fatal "Insecure permissions on #{rc_file}"
      exit 1
    end
  end

  def create_empty_rc_if_not_exists(rc_file)
    return if FileTest.exist?(rc_file)

    FileUtils.touch(rc_file)
    FileUtils.chmod(0600, rc_file)
  end

  def verify_rc_contents(rc_file)
    unless Object.const_defined?('RC')
      puts Achoo::Term.fatal "Malformed run control file: No RC constant defined"
      exit 1
    end

    %w(url user password).each do |key|
      unless RC.has_key?(key.to_sym)
        puts Achoo::Term.fatal "Missing mandatory run control configuration variable: #{key}"
        exit 1
      end
    end

    %w(vcs_dirs ical).each do |key|
      unless RC.has_key?(key.to_sym)
        puts Achoo::Term.warn "Missing run control configuration variable: #{key}. " \
             + "Add it to #{rc_file} to get rid of this warning"
        RC[key] = []
      end
    end
  end

end
