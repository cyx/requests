require 'json'
require 'net/http'
require 'uri'

module Requests
  def self.get(url, **kwargs)
    request('GET', url, **kwargs)
  end

  def self.post(url, data: nil, **kwargs)
    request('POST', url, data: data, **kwargs)
  end

  def self.put(url, data: nil, **kwargs)
    request('PUT', url, data: data, **kwargs)
  end

  def self.delete(url, **kwargs)
    request('DELETE', url, **kwargs)
  end

  def self.head(url, **kwargs)
    request('HEAD', url, **kwargs)
  end

  def self.options(url, **kwargs)
    request('OPTIONS', url, **kwargs)
  end

  def self.request(method, url,
    headers: {},
    data: nil,
    params: nil,
    auth: nil)

    uri = URI.parse(url)
    uri.query = URI.encode_www_form(params) if params

    body = _encode_params(headers: headers, data: data) if data

    _basic_auth(headers, *auth) if auth

    response = Net::HTTP.start(uri.host, uri.port) do |http|
      http.send_request(method, uri, body, headers)
    end

    if response.is_a?(Net::HTTPSuccess)
      Response.new(response.code, response.to_hash, response.body)
    else
      raise response.inspect
    end
  end

private
  def self._basic_auth(headers, user, pass)
    headers['Authorization'] = 'Basic ' + ["#{user}:#{pass}"].pack('m0')
  end

  def self._encode_params(headers: headers, data: data)
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
