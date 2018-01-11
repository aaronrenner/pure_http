defmodule PureHTTP do
  @moduledoc """
  Main API for PureHTTP
  """

  alias PureHTTP.Error
  alias PureHTTP.Logger
  alias PureHTTP.Request
  alias PureHTTP.Requestable
  alias PureHTTP.Response

  @type error_reason :: atom
  @type on_send :: {:ok, Response.t} | {:error, Error.t}

  @doc """
  Sends the `PureHTTP.Requestable`.
  """
  @spec send(Requestable.t, Keyword.t) :: on_send
  def send(requestable, opts \\ [])
  def send(%Request{} = request, opts) do
    request
    |> Logger.log_request
    |> send_request(opts)
    |> handle_httpoison_response
    |> Logger.log_response
  end
  def send(requestable, opts) do
    requestable |> Requestable.to_http_request |> __MODULE__.send(opts)
  end

  defp send_request(%Request{method: method, url: url, body: body, headers: headers}, opts) do
    HTTPoison.request(method, url, encode_body(body), headers, opts)
  end

  defp encode_body(body) when is_list(body), do: {:form, body}
  defp encode_body(body), do: body

  defp handle_httpoison_response({:ok, %HTTPoison.Response{} = response}) do
    {:ok, build_http_response(response)}
  end
  defp handle_httpoison_response({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, Error.exception(reason: reason)}
  end

  @spec build_http_response(HTTPoison.Response.t) :: Response.t
  defp build_http_response(%HTTPoison.Response{} = response) do
    Response.new(
      response.status_code,
      response.body,
      response.headers,
      response.request_url)
  end
end
