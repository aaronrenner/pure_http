defmodule PureHTTPTest do
  use ExUnit.Case, async: true

  import Plug.Conn

  alias PureHTTP, as: HTTP
  alias PureHTTP.Error
  alias PureHTTP.Request
  alias PureHTTP.Response
  alias PureHTTP.TestRequestable
  alias Plug.Parsers

  @moduletag :capture_log

  setup [:start_bypass]

  test "send/1 with a successful response", %{bypass: bypass} do
    Bypass.expect_once bypass, "GET", "/greeting.txt", fn conn ->
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "Hi Everybody!")
    end

    request = build_bypass_request(bypass, :get, "/greeting.txt")
    url = request.url

    {:ok, response} = HTTP.send(request)

    assert %Response{
      status_code: 200,
      body: "Hi Everybody!",
      headers: headers,
      request_url: ^url
    } = response

    assert_has_header headers, "content-type"
  end

  test "send/1 with a body and headers", %{bypass: bypass} do
    headers = [{"content-type", "application/json"}]
    request_body = ~s<{"username": "aaron"}>

    Bypass.expect_once bypass, "POST", "/greeting.txt", fn conn ->
      assert {:ok, ^request_body, conn} = read_body(conn)
      assert_has_header conn.req_headers, "content-type"

      send_resp(conn, 200, "Hi Everybody!")
    end

    assert {:ok, _} =
      bypass
      |> build_bypass_request(:post, "/greeting.txt", request_body, headers)
      |> HTTP.send
  end

  test "send/1 with a POST request and params", %{bypass: bypass} do
    headers = [{"content-type", "application/json"}]
    settings_json = ~s<{"setting_1": true}>
    post_body = [{"username", "aaron"}, {"settings", settings_json}]

    Bypass.expect_once bypass, "POST", "/greeting.txt", fn conn ->
      conn = parse_body(conn)
      assert conn.params == Enum.into(post_body, %{})
      assert_has_header conn.req_headers, "content-type"

      send_resp(conn, 200, "Hi Everybody!")
    end

    assert {:ok, _} =
      bypass
      |> build_bypass_request(:post, "/greeting.txt", post_body, headers)
      |> HTTP.send
  end

  test "send/1 with a custom Requestable", %{bypass: bypass} do
    Bypass.expect_once bypass, "GET", "/something.txt", fn conn ->
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "Hi Everybody!")
    end

    requestable = %TestRequestable{url: bypass_url(bypass, "/something.txt")}

    assert {:ok, _} = HTTP.send(requestable)
  end

  test "when unable to connect to the server", %{bypass: bypass} do
    Bypass.down(bypass)

    assert{:error, %Error{reason: :econnrefused}} =
      bypass
      |> build_bypass_request(:get, "/greeting.txt")
      |> HTTP.send
  end

  test "unknown domain" do
    request = %HTTP.Request{
      method: :get,
      url: "http://doesnotexist.activeprospect.com"}

    assert{:error, %Error{reason: :nxdomain}} = HTTP.send(request)
  end

  defp bypass_url(%Bypass{port: port}, path) do
    "http://localhost:#{port}/#{String.trim_leading(path, "/")}"
  end

  defp start_bypass(_) do
    {:ok, bypass: Bypass.open}
  end

  defp build_bypass_request(bypass, method, path, body \\ "", headers \\ []) do
    %Request{
      method: method,
      url: bypass_url(bypass, path),
      body: body,
      headers: headers}
  end

  defp assert_has_header(headers, key) do
    unless Enum.find(headers, &match?({^key, _}, &1)) do
      raise ExUnit.AssertionError, """
      Unable to find header: #{inspect key}

      Headers:
      #{inspect(headers, pretty: true)}
      """
    end
  end

  defp parse_body(conn) do
    parsers = ~w(urlencoded multipart json)a
    Parsers.call(conn, Parsers.init(parsers: parsers))
  end
end
