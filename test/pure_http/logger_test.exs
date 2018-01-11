defmodule PureHTTP.LoggerTest do
  use ExUnit.Case

  import PureHTTP.SettingsHelper
  import ExUnit.CaptureLog

  alias PureHTTP.Error
  alias PureHTTP.Logger, as: PureHTTPLogger
  alias PureHTTP.Request
  alias PureHTTP.Response

  setup [:set_log_level, :set_request_logging]

  describe "with logging turned on" do
    @describetag request_logging: true

    test "log_request/1" do
      request = Request.new(:post, "http://activeprospect.com", [{"accept", "application/json"}], "hello world")

      output = capture_log fn ->
        assert ^request = PureHTTPLogger.log_request(request)
      end
      assert output =~ "POST"
      assert output =~ "accept"
      assert output =~ "application/json"
      assert output =~ request.url
      assert output =~ "hello world"
    end

    test "log_response/1 on success" do
      status_code = 200
      body = ~s<{"hello": "world"}>
      headers = [{"content-type", "application/json"}]
      response = Response.new(status_code, body, headers)

      output = capture_log fn ->
        assert {:ok, ^response} = PureHTTPLogger.log_response({:ok, response})
      end
      assert output =~ inspect(status_code)
      assert output =~ inspect(body)
      assert output =~ inspect(headers)
    end

    test "log_response/1 on failure" do
      error = Error.exception(reason: :nxdomain)

      capture_log(fn ->
        assert {:error, ^error} = PureHTTPLogger.log_response({:error, error})
      end) =~ error.message
    end
  end

  describe "with logging turned off" do
    @describetag request_logging: false

    test "log_request/1" do
      request = Request.new(:post, "http://activeprospect.com", [{"accept", "application/json"}], "hello world")

      assert capture_log(fn ->
        assert ^request = PureHTTPLogger.log_request(request)
      end) == ""
    end

    test "log_response/1 on success" do
      status_code = 200
      body = ~s<{"hello": "world"}>
      headers = [{"content-type", "application/json"}]
      response = Response.new(status_code, body, headers)

      assert capture_log(fn ->
        assert {:ok, ^response} = PureHTTPLogger.log_response({:ok, response})
      end) == ""
    end

    test "log_response/1 on failure" do
      error = Error.exception(reason: :nxdomain)

      assert capture_log(fn ->
        assert {:error, ^error} = PureHTTPLogger.log_response({:error, error})
      end) == ""
    end
  end

  defp set_request_logging(context) do
    request_logging = Map.get(context, :request_logging, true)
    ensure_setting_is_reset(:pure_http, :request_logging)
    Application.put_env(:pure_http, :request_logging, request_logging)
  end

  defp set_log_level(_tags) do
    new_level = :debug
    orig = Logger.level
    on_exit fn ->
      Logger.configure(level: orig)
    end

    Logger.configure(level: new_level)
  end
end
