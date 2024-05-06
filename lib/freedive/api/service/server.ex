defmodule Freedive.Api.Service.Server do
  @moduledoc """
  Monitors a service (os-pid) on the host,
  publishes events to the `:service_monitor` topic.
  """
  use GenServer
  require Logger
  import Freedive.Api.Service.Cli

  @topic "host:service"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def list() do
    GenServer.call(__MODULE__, {:list})
  end

  @impl true
  def init(opts) do
    state = %{opts: opts, services: []}
    Logger.info("Starting Service.Server with opts: #{inspect(opts)}")
    Process.send_after(self(), :continue, 100)
    {:ok, state}
  end

  @impl true
  def handle_call({:list}, _from, state) do
    services = state[:services]
    {:reply, services, state}
  end

  @impl true
  def handle_info(:continue, state) do
    services =
      case list_services() do
        {:ok, services} -> services
        {:error, stderr} -> raise "Error listing services: #{stderr}"
      end

    state = %{state | services: services}
    {:noreply, state}
  end
end
