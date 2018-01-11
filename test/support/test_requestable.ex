defmodule PureHTTP.TestRequestable do
  @moduledoc false
  defstruct [:url]

  defimpl PureHTTP.Requestable do
    alias PureHTTP.Request

    def to_http_request(%@for{url: url}) do
      %Request{method: :get, url: url}
    end
  end
end
