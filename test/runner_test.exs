defmodule RunnerTest do
  use ExUnit.Case, async: true
  import Crawler.Runner.Impl

  import Mox

  setup do
    start_supervised({Task.Supervisor, name: Crawler.TaskSupervisor})

    :ok
  end

  def prevent_work(opts \\ []) do
    n = Keyword.get(opts, :invocations, 1)
    delay = Keyword.get(opts, :delay, 0)

    expect(CacheBehaviourMock, :update_status, n, fn _url, status ->
      assert :pending = status
    end)

    expect(TaskBehaviourMock, :fetch, n, fn _url ->
      :timer.sleep(delay)
      nil
    end)
  end

  describe "start/1" do
    test "doesn't start task when status is :success" do
      expect(CacheBehaviourMock, :get_status, fn url ->
        assert "Test" = url

        :success
      end)

      assert :success = start("Test")
      assert 0 = Supervisor.count_children(Crawler.TaskSupervisor).workers
    end

    test "doesn't start task when status is :pending" do
      expect(CacheBehaviourMock, :get_status, fn url ->
        assert "Test" = url

        :pending
      end)

      assert :pending = start("Test")
      assert 0 = Supervisor.count_children(Crawler.TaskSupervisor).workers
    end

    test "doesn't start task when status is :failed" do
      expect(CacheBehaviourMock, :get_status, fn url ->
        assert "Test" = url

        :failed
      end)

      assert :failed = start("Test")
      assert 0 = Supervisor.count_children(Crawler.TaskSupervisor).workers
    end

    test "starts task when status is nil" do
      expect(CacheBehaviourMock, :get_status, fn url ->
        assert "Test" = url

        nil
      end)

      prevent_work()

      assert {:ok, _} = start("Test")
      assert 1 = Supervisor.count_children(Crawler.TaskSupervisor).workers
    end

    test "starts task when status is :retry" do
      expect(CacheBehaviourMock, :get_status, fn url ->
        assert "Test" = url

        :retry
      end)

      prevent_work()

      assert {:ok, _} = start("Test")
      assert 1 = Supervisor.count_children(Crawler.TaskSupervisor).workers
    end
  end

  describe "is_last_task?/0" do
    test "returns true when called on the last task" do
      expect(CacheBehaviourMock, :get_status, fn url ->
        assert "Test" = url

        nil
      end)

      prevent_work()

      assert {:ok, _} = start("Test")
      assert 1 = Supervisor.count_children(Crawler.TaskSupervisor).workers

      assert true = is_last_task?()
    end

    test "returns false when called on the penultimate task" do
      expect(CacheBehaviourMock, :get_status, 2, fn _url ->
        nil
      end)

      prevent_work(invocations: 2, delay: 1000)

      assert {:ok, _} = start("Test")
      assert {:ok, _} = start("Test2")
      assert 2 = Supervisor.count_children(Crawler.TaskSupervisor).workers

      assert false == is_last_task?()
    end
  end
end
