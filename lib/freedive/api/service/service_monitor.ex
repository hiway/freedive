defmodule Freedive.Api.Service.ServiceMonitor do
  @moduledoc """
  Monitors a service (os-pid) on the host,
  publishes events to the `:service_monitor` topic.
  """
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    Logger.info("Starting ServiceMonitor")
    {:ok, opts}
  end
end
