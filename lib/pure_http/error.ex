defmodule PureHTTP.Error do
  @moduledoc """
  Indicates there was an error making the HTTP request.

  This means the request was unable to be completed due to something like a
  network error. This struct will not be returned due to an unexpected status
  code like 500 - internal server error.
  """

  defexception [:message, :reason]
  @type t :: %__MODULE__{
    message: String.t,
    reason: term,
  }

  def exception(opts) do
    reason = Keyword.fetch!(opts, :reason)
    message = "error completing HTTP request: #{inspect reason}"
    %__MODULE__{message: message, reason: reason}
  end
end
