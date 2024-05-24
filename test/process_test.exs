defmodule ProcessTest do
  use ExUnit.Case, async: true
  import Crawler.Process.Impl

  import Mox

  describe "crawl/1" do
    test "returns when encountering an unknown error" do
      expect(HttpBehaviourMock, :get, fn url, args ->
        assert "" = url
        assert [timeout: 10_000, recv_timeout: 10_000] = args
        {:error, :unknown}
      end)

      assert {:error, :unknown_error, {:error, :unknown}} = crawl("")
    end

    test "returns HTTPoison error reason" do
      expect(HttpBehaviourMock, :get, fn url, args ->
        assert "" = url
        assert [timeout: 10_000, recv_timeout: 10_000] = args
        {:error, %HTTPoison.Error{reason: "test reason"}}
      end)

      assert {:error, "test reason"} = crawl("")
    end

    test "returns error when encountering unexpected status code" do
      expect(HttpBehaviourMock, :get, fn url, args ->
        assert "" = url
        assert [timeout: 10_000, recv_timeout: 10_000] = args
        {:ok, %HTTPoison.Response{status_code: 999}}
      end)

      assert {:error, :unexpected_status, 999} = crawl("")
    end

    test "returns redirect error when encountering 301" do
      expect(HttpBehaviourMock, :get, fn url, args ->
        assert "" = url
        assert [timeout: 10_000, recv_timeout: 10_000] = args
        {:ok, %HTTPoison.Response{status_code: 301, headers: [{"Location", "NEW_URL"}]}}
      end)

      assert {:error, :redirect, "NEW_URL"} = crawl("")
    end

    test "returns redirect error when encountering 302" do
      expect(HttpBehaviourMock, :get, fn url, args ->
        assert "" = url
        assert [timeout: 10_000, recv_timeout: 10_000] = args
        {:ok, %HTTPoison.Response{status_code: 302, headers: [{"Location", "NEW_URL"}]}}
      end)

      assert {:error, :redirect, "NEW_URL"} = crawl("")
    end

    test "returns body when encountering 2XX" do
      expect(HttpBehaviourMock, :get, fn url, args ->
        assert "" = url
        assert [timeout: 10_000, recv_timeout: 10_000] = args
        {:ok, %HTTPoison.Response{status_code: 200, body: "BODY"}}
      end)

      assert {:ok, "BODY"} = crawl("")
    end
  end

  describe "process_urls/2" do
    test "removes invalid links" do
      base = "https://test.com"
      Application.put_env(:crawler, :init_url, base)

      valid = "#{base}/homepage"

      assert [^valid] =
               ["/", "/", base, "#{base}/homepage", "https://facebook.com"]
               |> process_urls(base)
               |> Enum.into([])
    end

    test "normalizes links" do
      base = "https://test.com"
      Application.put_env(:crawler, :init_url, base)

      valid = "#{base}/homepage"

      assert [^valid] =
               ["/", "/", base, "#{base}/homepage#this_is_a_header", "https://facebook.com"]
               |> process_urls(base)
               |> Enum.into([])
    end

    test "prepends the base to valid links" do
      base = "https://test.com"
      Application.put_env(:crawler, :init_url, base)

      valid = "#{base}/homepage"

      assert [^valid] =
               ["/", "/", base, "/homepage#this_is_a_header", "https://facebook.com"]
               |> process_urls(base)
               |> Enum.into([])
    end
  end

  describe "parse/1" do
    # TODO: Floki doesn't utilize behaviours so interactions need to be extracted into a behaviour interface to properly mock it
    test "returns the href links from a tags in an HTML document" do
      body = """
      <html>
      <body>
        <a href="https://google.com">Here's a link</a>
      </body>
      """

      assert {:ok, ["https://google.com"]} = parse(body)
    end
  end
end
