defmodule CacheTest do
  use ExUnit.Case, async: true
  import Crawler.Cache.Impl

  setup do
    start_supervised(Crawler.Cache.Impl, %{})

    :ok
  end

  describe "get_status/2" do
  end

  test "get_status/2 returns nil when no status is set" do
    assert nil == get_status("NO STATUS SET")
  end

  test "get_status/2 returns the pre-set URL status" do
    update_status("1", :testing)
    assert :testing == get_status("1")
  end

  test "update_status/3 updates the status for a URL" do
    assert nil == get_status("1")
    update_status("1", :testing)
    assert :testing == get_status("1")
  end

  test "update_status/4 stores the required metadata for a URL" do
    assert nil == get_status("1")
    update_status("1", :testing, %{meta: "data"})
    assert :testing == get_status("1")
    assert %{meta: "data"} == Map.get(get(), "1").meta
  end
end
