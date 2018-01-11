defmodule PureHTTP.Request do
  @moduledoc """
  A HTTP Request.
  """

  @typedoc """
  Use `binary` to send raw data or a keyword list to send form data.
  """
  @type body :: binary | Keyword.t
  @type url :: String.t
  @type headers :: [{binary, binary}]
  @type method :: :get | :post | :put | :delete

  @http_methods [:get, :post, :put, :delete]

  defstruct method: nil, url: nil, body: "", headers: []
  @type t :: %__MODULE__{
    method: method,
    url: url,
    body: body,
    headers: headers
  }

  @doc """
  Builds a new `PureHTTP.Request`.
  """
  @spec new(method, url, headers, body) :: t
  def new(method, url, headers \\ [], body \\ "") when method in @http_methods and is_binary(url) do
    %__MODULE__{method: method, url: url, headers: headers, body: body}
  end

  defimpl PureHTTP.Requestable do
    def to_http_request(request), do: request
  end
end
