defmodule PureHTTP.ResponseTest do
  use ExUnit.Case, async: true

  alias PureHTTP.Response

  describe "new/4" do
    test "generates the approprate struct" do
      status_code = 200
      body = "hello"
      headers = [{"content-type", "text/plain"}]
      request_url = "http://example.com"

      assert %Response{
        status_code: ^status_code,
        body: ^body,
        headers: ^headers,
        request_url: ^request_url
      } = Response.new(status_code, body, headers, request_url)
    end

    test "defaults headers and request url" do
      status_code = 200
      body = "hello"

      assert %Response{
        status_code: ^status_code,
        body: ^body,
        headers: [],
        request_url: nil
      } = Response.new(status_code, body)
    end

    test "downcases header keys" do
      orig_headers =
        [{"Content-Type", "application/json"},
         {"x-test-header", "A"}]

      %Response{headers: new_headers} = Response.new(200, "", orig_headers)

      assert new_headers ==
        [{"content-type", "application/json"},
         {"x-test-header", "A"}]
    end
  end

  describe "get_header/2" do
    test "returns the values for the given header by name" do
      headers =
        [{"Content-Type", "application/json"},
         {"content-type", "text/text"},
         {"x-test-header", "A"}]

      response = Response.new(200, "", headers)

      assert ["application/json", "text/text"] = Response.get_header(response, "content-type")
    end
  end
end
