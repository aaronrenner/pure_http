defmodule PureHTTP.Response do
  @moduledoc """
  A HTTP Response.
  """

  @type status_code :: integer
  @type body :: binary
  @type headers :: [{binary, binary}]
  @type request_url :: nil | String.t

  defstruct status_code: nil, body: nil, headers: [], request_url: nil
  @type t :: %__MODULE__{
    status_code: integer,
    body: term,
    headers: headers,
    request_url: request_url,
  }

  @spec new(status_code, body, headers, request_url) :: __MODULE__.t
  def new(status_code, body, headers \\ [], request_url \\ nil) do
    %__MODULE__{
      status_code: status_code,
      body: body,
      headers: normalize_headers(headers),
      request_url: request_url}
  end

  @spec get_header(t, binary) :: [binary]
  def get_header(%__MODULE__{headers: headers}, key) do
    key = String.downcase(key)

    headers
    |> Enum.filter(&match?({^key, _}, &1))
    |> Enum.map(fn({_, v}) -> v end)
  end

  @spec normalize_headers(headers) :: headers
  defp normalize_headers([{key, value} | rest]) do
    [{String.downcase(key), value} | normalize_headers(rest)]
  end
  defp normalize_headers([]), do: []
end
