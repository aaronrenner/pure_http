defprotocol PureHTTP.Requestable do
  @moduledoc """
  The `#{inspect __MODULE__}` protocol is responsible for converting an Elixir
  data structure into a HTTP request.
  """
  alias PureHTTP.Request

  @spec to_http_request(term) :: Request.t
  def to_http_request(data)
end
