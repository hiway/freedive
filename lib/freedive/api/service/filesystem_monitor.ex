defmodule Freedive.Api.Service.FilesystemMonitor do
  @moduledoc """
  Monitors relevant paths on the host,
  publishes events to the `:filesystem_monitor` topic.
  """
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    Logger.info("Starting FilesystemMonitor")
    {:ok, opts}
  end
end
