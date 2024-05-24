defmodule Crawler.Process.Impl do
  @behaviour Crawler.Process.Behaviour

  @redirect_responses [301, 302]

  @impl Crawler.Process.Behaviour
  def crawl(url) when is_binary(url) do
    case http_client().get(url, timeout: 10_000, recv_timeout: 10_000) do
      {:ok, %HTTPoison.Response{status_code: status_code, body: body}}
      when status_code >= 200 and status_code < 300 ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: status_code, headers: headers}}
      when status_code in @redirect_responses ->
        {_, value} = Enum.find(headers, fn {header, _} -> header == "Location" end)
        {:error, :redirect, value}

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, :unexpected_status, status_code}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}

      err ->
        {:error, :unknown_error, err}
    end
  end

  @impl Crawler.Process.Behaviour
  def parse(body) when is_binary(body) do
    with {:ok, document} <- Floki.parse_document(body) do
      {:ok, Floki.attribute(document, "a[href]", "href")}
    end
  end

  @impl Crawler.Process.Behaviour
  def process_urls(urls, base) when is_binary(base) do
    urls
    |> Stream.filter(&valid_link?(base, &1))
    |> Stream.map(&normalize/1)
    |> Stream.map(&build/1)
  end

  defp valid_link?(origin, target) when origin == target, do: false
  defp valid_link?(_state, "/"), do: false
  defp valid_link?(_state, "/" <> _), do: true
  defp valid_link?(origin, target), do: URI.parse(origin).host == URI.parse(target).host

  defp normalize("/" <> _ = url),
    do: String.split(url, "#", parts: 2) |> Enum.at(0)

  defp normalize(url), do: URI.parse(url).path

  defp build(nil), do: get_base() <> "/"
  defp build(url), do: get_base() <> url

  defp get_base() do
    %{scheme: scheme, host: host} = Application.get_env(:crawler, :init_url) |> URI.parse()

    "#{scheme}://#{host}"
  end

  defp http_client() do
    Application.get_env(:bound, :http_client, HTTPoison)
  end
end
