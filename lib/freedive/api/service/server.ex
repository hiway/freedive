defmodule Freedive.Api.Service.Server do
  @moduledoc """
  Monitors a service (os-pid) on the host,
  publishes events to the `:service_monitor` topic.
  """
  use GenServer
  require Logger
  alias Freedive.Api.Service
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

    Service.subscribe()
    state = %{state | services: services}
    {:noreply, state}
  end

  def handle_info({@topic <> ":" <> event, {:error, log}}, state) do
    Logger.error("Service.Server event: #{event}, log: #{inspect(log)}")

    service =
      state[:services]
      |> Enum.find(&(&1[:name] == event))

    case event do
      "stopped" ->
        service = %{service | running: false}
        state = %{state | services: state[:services] ++ [service]}
        {:ok, state}

      _ ->
        {:noreply, state}
    end
  end

  def handle_info({@topic <> ":" <> event, {:ok, payload}}, state) do
    Logger.warning("Service.Server event: #{event}, payload: #{inspect(payload)}")

    service =
      state[:services]
      |> Enum.find(&(&1[:name] == event))

    case event do
      "running" ->
        service = %{service | running: true}
        state = %{state | services: state[:services] ++ [service]}
        {:ok, state}

      _ ->
        {:noreply, state}
    end

    {:noreply, state}
  end
end
