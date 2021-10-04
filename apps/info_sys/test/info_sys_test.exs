defmodule InfoSysTest do
  use ExUnit.Case
  doctest InfoSys

  alias InfoSys.Result

  defmodule TestBackend do
    @behaviour InfoSys.Backend

    @impl true
    def name, do: "test"

    @impl true
    def compute(query_str, _opts) do
      query_str
      |> build_results()
    end

    defp build_results("result") do
      [%Result{backend: TestBackend, text: "result"}]
    end

    defp build_results("none"), do: []

    defp build_results("timeout") do
      :timer.sleep(:infinity)
    end

    defp build_results("boom") do
      raise "boom!"
    end
  end

  test "compute/2 with backend results" do
    assert [%Result{backend: InfoSysTest.TestBackend, text: "result"}] =
             InfoSys.compute("result", backends: [TestBackend])
  end

  test "compute/2 with no backend results" do
    assert [] = InfoSys.compute("none", backends: [TestBackend])
  end

  test "compute/2 with timeout returns no results and kills workers" do
    results = InfoSys.compute("timeout", backends: [TestBackend], timeout: 10)
    assert results == []
    refute_received :timedout
  end

  @tag :capture_log
  test "compute/2 discards backend errors" do
    assert InfoSys.compute("boom", backends: [TestBackend]) == []
    refute_received :timedout
  end
end
