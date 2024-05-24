defmodule TaskTest do
  use ExUnit.Case, async: true
  import Crawler.Task.Impl

  import Mox

  describe "fetch/1" do
    test "attempts retry when an unexpected error occurs" do
      expect(ProcessBehaviourMock, :crawl, fn url ->
        assert "" = url
        {:error, :unknown_error}
      end)

      expect(CacheBehaviourMock, :update_status, fn url, status ->
        assert "" = url
        assert :retry = status
      end)

      assert :error = fetch("")
    end

    test "attempts retry when a timeout occurs" do
      expect(ProcessBehaviourMock, :crawl, fn url ->
        assert "" = url
        {:error, :timeout}
      end)

      expect(CacheBehaviourMock, :update_status, fn url, status ->
        assert "" = url
        assert :retry = status
      end)

      assert :error = fetch("")
    end

    test "saves when a binary file is returned" do
      expect(ProcessBehaviourMock, :crawl, fn url ->
        assert "" = url
        {:error, "cannot transform bytes from binary to a valid UTF8 string"}
      end)

      expect(CacheBehaviourMock, :update_status, fn url, status ->
        assert "" = url
        assert :binary = status
      end)

      assert :ok = fetch("")
    end

    test "saves when an unexpected status code is returned" do
      expect(ProcessBehaviourMock, :crawl, fn url ->
        assert "" = url
        {:error, :unexpected_status, 999}
      end)

      expect(CacheBehaviourMock, :update_status, fn url, status, meta ->
        assert "" = url
        assert :unexpected = status
        assert %{unexpected_status_code: 999} = meta
      end)

      assert :ok = fetch("")
    end

    test "saves when a url is not found" do
      expect(ProcessBehaviourMock, :crawl, fn url ->
        assert "" = url
        {:error, :unexpected_status, 404}
      end)

      expect(CacheBehaviourMock, :update_status, fn url, status ->
        assert "" = url
        assert :not_found = status
      end)

      assert :ok = fetch("")
    end

    test "follows a redirect provided by the webserver" do
      expect(ProcessBehaviourMock, :crawl, fn url ->
        assert "" = url
        {:error, :redirect, "NEW"}
      end)

      expect(CacheBehaviourMock, :update_status, fn url, status, meta ->
        assert "" = url
        assert :redirect = status
        assert %{redirect_location: "NEW"} = meta
      end)

      expect(ProcessBehaviourMock, :process_urls, fn args, base ->
        assert ["NEW"] = args
        assert "" = base
        args
      end)

      expect(RunnerBehaviourMock, :start, fn url ->
        assert "NEW" = url
        nil
      end)

      assert :ok = fetch("")
    end

    test "processes any found urls" do
      expect(ProcessBehaviourMock, :crawl, fn url ->
        assert "" = url
        {:ok, "body"}
      end)

      expect(ProcessBehaviourMock, :parse, fn body ->
        assert "body" = body
        {:ok, ["1", "2"]}
      end)

      expect(ProcessBehaviourMock, :process_urls, fn args, base ->
        assert ["1", "2"] = args
        assert "" = base
        args
      end)

      expect(CacheBehaviourMock, :update_status, fn url, status, meta ->
        assert "" = url
        assert :success = status
        assert %{processed_links: ["1", "2"]} = meta
      end)

      expect(RunnerBehaviourMock, :start, 2, fn _url ->
        nil
      end)

      assert :ok = fetch("")
    end
  end
end
