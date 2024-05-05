defmodule Freedive.Api.Service do
  @moduledoc """
  Monitor and manage services running on host.
  """
  import Freedive.Api.Service.Cli
  @topic "host:service"

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
      {:ok, services} -> {:ok, services}
      {:error, stderr} -> {:error, stderr}
    end
  end

  def service(name) do
    case list_commands(name) do
      {:ok, commands} ->
        %{name: name, running: is_running?(name), commands: commands}

      {:error, stderr} ->
        %{name: name, running: is_running?(name), commands: [], error: stderr}
    end
  end

  def start(name, args \\ []) do
    case start_service(name, args) do
      {:ok, stdout} -> {:ok, stdout_to_log(stdout)}
      {:error, stderr} -> {:error, stderr_to_log(stderr)}
    end
  end

  def stop(name, args \\ []) do
    case stop_service(name, args) do
      {:ok, stdout} -> {:ok, stdout_to_log(stdout)}
      {:error, stderr} -> {:error, stderr_to_log(stderr)}
    end
  end

  def restart(name, args \\ []) do
    case stop(name, args) do
      {:ok, stdout_stop} ->
        case start(name, args) do
          {:ok, stdout_start} -> {:ok, stdout_start ++ stdout_stop}
          {:error, stderr} -> {:error, stderr}
        end

      {:error, stderr} ->
        {:error, stderr}
    end
  end

  def run_command(name, command, args \\ []) do
    case run_service_command(name, command, args) do
      {:ok, stdout} -> {:ok, stdout_to_log(stdout)}
      {:error, stderr} -> {:error, stderr_to_log(stderr)}
    end
  end

  def list_commands(name, args \\ []) do
    case list_service_commands(name, args) do
      {:ok, commands} -> {:ok, commands}
      {:error, stderr} -> {:error, stderr}
    end
  end

  def is_running?(name, args \\ []) do
    case service_is_running?(name, args) do
      true -> true
      false -> false
    end
  end

  defp stdout_to_log(stdout) do
    stdout
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reverse()
  end

  defp stderr_to_log(stderr) do
    stderr
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.reverse()
  end
end
