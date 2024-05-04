defmodule Freedive.Api.Service do
  @moduledoc """
  Monitor and manage services running on host.
  """
  import Freedive.Api.Service.Cli
  @topic "host:services"

  def topic do
    @topic
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Freedive.PubSub, @topic)
  end

  def unsubscribe do
    Phoenix.PubSub.unsubscribe(Freedive.PubSub, @topic)
  end

  def list() do
    case list_services() do
      {:ok, stdout} -> {:ok, stdout}
      {:error, stderr} -> {:error, stderr}
    end
  end

  def start(name, args \\ []) do
    case start_service(name, args) do
      {:ok, stdout} -> {:ok, stdout}
      {:error, stderr} -> {:error, stderr}
    end
  end

  def stop(name, args \\ []) do
    case stop_service(name, args) do
      {:ok, stdout} -> {:ok, stdout}
      {:error, stderr} -> {:error, stderr}
    end
  end

  def is_running?(name, args \\ []) do
    case service_is_running?(name, args) do
      true -> true
      false -> false
    end
  end
end
