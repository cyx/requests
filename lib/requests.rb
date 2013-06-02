require 'json'
require 'net/http'
require 'openssl'
require 'uri'

module Requests
  Error = Class.new(StandardError)

  CA_FILE = ENV.fetch('REQUESTS_CA_FILE',
                      File.expand_path('../cacert.pem', __FILE__))

  def self.request(method, url,
    headers: {},
    data: nil,
    params: nil,
    auth: nil)

    uri = URI.parse(url)
    uri.query = URI.encode_www_form(params) if params

    body = process_params(headers: headers, data: data) if data

    basic_auth(headers, *auth) if auth

    response = Net::HTTP.start(uri.host, uri.port, opts(uri)) do |http|
      http.send_request(method, uri, body, headers)
    end

    if response.is_a?(Net::HTTPSuccess)
      Response.new(response.code, response.to_hash, response.body)
    else
      raise Error, response.inspect
    end
  end

private
  def self.opts(uri)
    if uri.scheme == 'https'
      { use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_PEER,
        ca_file: CA_FILE
      }
    end
  end

  def self.basic_auth(headers, user, pass)
    headers['Authorization'] = 'Basic ' + ["#{user}:#{pass}"].pack('m0')
  end

  def self.process_params(headers: nil, data: nil)
    if not data.kind_of?(Enumerable)
      data
    else
      headers['content-type'] = 'application/x-www-form-urlencoded'

      URI.encode_www_form(data)
    end
  end

  class Response
    attr :status_code
    attr :headers
    attr :content

    def initialize(status_code, headers, content)
      @status_code, @headers, @content = Integer(status_code), headers, content
    end

    # TODO Verify that JSON can parse data without encoding stuff
    def json
      JSON.parse(@content)
    end

    # TODO Verify that this is based on content-type header
    def encoding
      @content.encoding
    end

    # TODO this will probably do something related to encoding if necessary
    def text
      @content
    end
  end
end
