# requests

Requests: HTTP for Humans

## Description

Inspired by the Requests library for Python, this gem provides an
easy way to issue HTTP requests.

## Usage

Here's an example of a GET request:

```ruby
require "requests"

response = Requests.request("GET", "http://example.com")

# Now you have these methods available
response.status  #=> Number with the status code
response.headers #=> Hash with the response headers
response.body    #=> String with the response body
```

If instead of calling `Requests.request` you prefer to specify the
HTTP method directly, you can use `requests/sugar` instead:

```ruby
require "requests/sugar"

response = Requests.get("http://example.com")

# And again you get a response
response.status  #=> Number with the status code
response.headers #=> Hash with the response headers
response.body    #=> String with the response body
```

You can also pass parameters with a query string:

```ruby
# GET http://example.com?foo=bar
Requests.get("http://example.com", params: { foo: "bar" })
```

If you want to send data with a POST request, you can add a `data`
option with the value.

```ruby
Requests.post("http://example.com", data: "hello world")
```

For Basic Authentication, you can provide the option `auth`, which
should contain an array with the username and password:

```ruby
Requests.get("http://example.com", auth: ["username", "password"])
```

## Installation

As usual, you can install it using rubygems.

```
$ gem install requests
```
