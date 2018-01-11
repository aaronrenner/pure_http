defmodule PureHTTP.RequestTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias PureHTTP.Request
  alias PureHTTP.Requestable

  @http_methods [:get, :post, :put, :delete]

  property "new/2 with valid arguments" do
    check all method <- member_of(@http_methods),
              url <- binary() do

      assert %Request{method: ^method, url: ^url, headers: [], body: ""} =
        Request.new(method, url)
    end
  end

  property "new/2 does not allow invalid http methods" do
    check all method <- term(),
            not method in @http_methods do

      assert_raise FunctionClauseError, fn ->
        Request.new(method, "http://www.activeprospect.com")
      end
    end
  end

  property "new/2 does not allow a non-binary url" do
    check all url <- term(),
            not is_binary(url) do
      method = :get

      assert_raise FunctionClauseError, fn ->
        Request.new(method, url)
      end
    end
  end

  describe "Requestable.to_http_request/1" do
    test "returns the http request unmodified" do
      request =
        Request.new(:get, "https://graph.facebook.com/v2.10/me", [], "hello")

      assert Requestable.to_http_request(request) == request
    end
  end
end
