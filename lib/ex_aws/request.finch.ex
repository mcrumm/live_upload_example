defmodule ExAws.Request.Finch do
  @moduledoc """
  A Finch implementation of the ExAws [`HttpClient`](`ExAws.Request.HttpClient`) behaviour.
  """
  @behaviour ExAws.Request.HttpClient

  @impl true
  def request(method, url, req_body, headers, http_opts) do
    opts = Application.get_env(:ex_aws, __MODULE__, [])

    {finch_name, opts} = Keyword.pop(opts, :finch)

    unless finch_name do
      raise ArgumentError, """
      The :finch option is required to use #{inspect(__MODULE__)}, for example:

          config :ex_aws, ExAws.Request.Finch, finch: MyApp.Finch

      """
    end

    req = Finch.build(method, url, headers, req_body, http_opts ++ opts)

    case Finch.request(req, finch_name) do
      {:ok, resp} -> {:ok, http_client_response(resp)}
      {:error, exception} -> {:error, %{reason: exception}}
    end
  end

  defp http_client_response(resp) do
    %Finch.Response{body: body, headers: headers, status: status} = resp
    %{body: body, headers: headers, status_code: status}
  end
end
