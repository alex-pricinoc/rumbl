#---
# Excerpted from "Programming Phoenix 1.4",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit http://www.pragmaticprogrammer.com/titles/phoenix14 for more book information.
#---
defmodule InfoSys.Cache do
  use GenServer

  @clear_interval :timer.seconds(60)

  def put(name \\ __MODULE__, key, value) do
    true = :ets.insert(tab_name(name), {key, value})

    :ok
  end

  def fetch(name \\ __MODULE__, key) do
    {:ok, :ets.lookup_element(tab_name(name), key, 2)}
  rescue
    ArgumentError -> :error
  end

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end
  
  @clear_interval :timer.seconds(60)

  def init(opts) do
    state = %{
      interval: opts[:clear_interval] || @clear_interval,
      timer: nil,
      table: new_table(opts[:name])
    }

    {:ok, schedule_clear(state)}
  end

  def handle_info(:clear, state) do 
    :ets.delete_all_objects(state.table)
    {:noreply, schedule_clear(state)}
  end

  defp schedule_clear(state) do 
    %{state | timer: Process.send_after(self(), :clear, state.interval)}
  end

  def init(opts) do
    state = %{
      interval: opts[:clear_interval] || @clear_interval,
      timer: nil,
      table: new_table(opts[:name])
    }

    {:ok, schedule_clear(state)}
  end

  def handle_info(:clear, state) do
    :ets.delete_all_objects(state.table)
    {:noreply, schedule_clear(state)}
  end

  defp schedule_clear(state) do
    %{state | timer: Process.send_after(self(), :clear, state.interval)}
  end

  defp new_table(name) do
    name
    |> tab_name()
    |> :ets.new([:set, :named_table, :public, read_concurrency: true, write_concurrency: true])
  end

  defp tab_name(name), do: :"#{name}_cache"
end
