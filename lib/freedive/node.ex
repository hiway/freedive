defmodule Freedive.Node.Server do
  @moduledoc """
  Track and manage nodes in cluster.
  """
  use GenServer
  alias Freedive.NodeTracker
  require Logger

  @refresh 2_000
  @jitter 100
  @topic "nodes"

  def topic(), do: @topic

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    state = %{
      hostname: "unknown"
    }

    Process.send_after(self(), :track_this_node, 500)
    Process.send_after(self(), :refresh, @refresh + :rand.uniform(@jitter))
    {:ok, state}
  end

  def handle_info(:track_this_node, state) do
    hostname = Freedive.Hostname.hostname()
    state = Map.update!(state, :hostname, fn _ -> hostname end)
    Phoenix.Tracker.track(NodeTracker, self(), @topic, hostname, state)
    Logger.info("Freedive.Node: start tracking this node: #{hostname}")
    {:noreply, state}
  end

  def handle_info(:refresh, state) do
    state = refresh_and_broadcast(state)
    Process.send_after(self(), :refresh, @refresh + :rand.uniform(@jitter))
    {:noreply, state}
  end

  defp refresh_and_broadcast(state) do
    hostname = Freedive.Hostname.hostname()
    hostname_prev = state[:hostname]

    if hostname != hostname_prev do
      Logger.info("Freedive.Node: hostname changed from #{hostname_prev} to #{hostname}")
      broadcast_hostname_change(hostname, state)
    else
      state
    end
  end

  defp broadcast_hostname_change(hostname, state) do
    state = Map.update!(state, :hostname, fn _ -> hostname end)
    Phoenix.Tracker.update(NodeTracker, self(), @topic, hostname, state)
    state
  end
end
