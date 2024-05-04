defmodule Freedive.Api.Service.CommandMonitor do
  @moduledoc """
  Monitors `service` commands executed on the host,
  publishes events to the `:service_command` topic.
  """
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    Logger.info("Starting CommandMonitor")
    {:ok, opts}
  end
end
