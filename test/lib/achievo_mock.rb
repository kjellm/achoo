# From http://dynamicorange.com/2009/02/18/ruby-mock-web-server/

require 'logger'
require 'rack'
require 'thin'

class AchievoMock

  def initialize(host='127.0.0.1', port=4000)
    @expectations = []
    @server = Thin::Server.new(host, port, self)
    @server.silent = true
    @thread = Thread.new { @server.start }
    @logger = Logger.new(File.dirname(__FILE__) + '/../../tmp/test.log')
  end

  def stop
    @server.stop!
    Thread.kill(@thread)
  end

  def register(method, path, response, env={})
    env.merge!({
      'REQUEST_METHOD' => method.to_s.upcase,
      'REQUEST_PATH'   => path,
    })
    @logger.debug "Registered #{[env, response]}"
    @expectations << [env, response]
  end

  def clear()
    @expectations = []
  end

  def call(env)
    @logger.debug "Got request: #{env}"

    if @expectations.empty?
      @logger.debug('Got an unexpected request')
      return error_page('Not expecting any request')
    end

    expectation = @expectations.shift
    expectationEnv = expectation[0]
    response = expectation[1]
    response[1] = { 'Content-Type' => 'text/html', 'Content-Length' => response[2].length.to_s }
    response[2] = [response[2]]
    matched = false
    expectationEnv.each do |envKey, value|
      matched = true
      if value != env[envKey]
        matched = false
        @logger.debug('Unmet expectation')
        return error_page('Expectation not met')
      end
    end
    if matched
      @logger.debug "Responding with: #{response}"
      return response
    end
  end

  def error_page(msg)
    [500, 
     { 'Content-Type'   => 'text/plain', 
       'Content-Length' => msg.length.to_s
     }, 
     [msg]
    ]
  end
end

