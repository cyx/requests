require 'requests'

module Requests
  module Sugar
    def get(url, **kwargs)
      request('GET', url, **kwargs)
    end

    def post(url, data: nil, **kwargs)
      request('POST', url, data: data, **kwargs)
    end

    def put(url, data: nil, **kwargs)
      request('PUT', url, data: data, **kwargs)
    end

    def delete(url, **kwargs)
      request('DELETE', url, **kwargs)
    end

    def head(url, **kwargs)
      request('HEAD', url, **kwargs)
    end

    def options(url, **kwargs)
      request('OPTIONS', url, **kwargs)
    end

    def patch(url, **kwargs)
      request('PATCH', url, **kwargs)
    end

    def trace(url, **kwargs)
      request('TRACE', url, **kwargs)
    end
  end

  extend Sugar
end
