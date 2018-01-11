defmodule PureHTTP.Logger do
  @moduledoc false

  alias PureHTTP.Error
  alias PureHTTP.Request
  alias PureHTTP.Response

  require Logger

  @spec log_request(Request.t) :: Request.t
  def log_request(%Request{method: method, url: url, body: body, headers: headers} = request) do
    """
    [PureHTTP] Sending request - #{format_method method} #{url}
      Headers: #{inspect headers}
      Body: #{inspect body}"
    """
    |> String.trim
    |> log(:debug)

    request
  end

  @spec log_response(PureHTTP.on_send) :: PureHTTP.on_send
  def log_response({:ok, %Response{status_code: status_code, body: body, headers: headers}} = on_send) do
    """
    [PureHTTP] Received #{inspect status_code} response
      Headers: #{inspect headers}
      Body: #{inspect body}"
    """
    |> String.trim
    |> log(:debug)

    on_send
  end
  def log_response({:error, %Error{message: message}} = on_send) do
    """
    [PureHTTP] #{message}
    """
    |> String.trim
    |> String.capitalize
    |> log(:warn)

    on_send
  end

  @spec format_method(Request.method) :: String.t
  defp format_method(method) do
    method |> to_string |> String.upcase
  end

  @spec log(Logger.message, Logger.level) :: :ok
  defp log(message, level) do
    if request_logging?() do
      Logger.log(level, message)
    else
      :ok
    end
  end

  @spec request_logging? :: boolean
  defp request_logging? do
    Application.get_env(:pure_http, :request_logging, false)
  end
end
