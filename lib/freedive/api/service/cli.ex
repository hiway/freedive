defmodule Freedive.Api.Service.Cli do
  @moduledoc """
  Wrapper around `service` command on FreeBSD.
  """
  require Logger
  import Freedive
  alias Freedive.Api.Service

  @service_bin "/usr/sbin/service"
  @topic "host:service"

  def topic do
    @topic
  end

  def list_services() do
    case execute(@service_bin, ["-l"]) do
      {:ok, stdout} ->
        service_names =
          stdout
          |> String.split("\n")
          |> Enum.map(&String.trim/1)
          |> Enum.reject(
            &Enum.member?(["DAEMON", "FILESYSTEMS", "LOGIN", "NETWORKING", "SERVERS"], &1)
          )

        case execute(@service_bin, ["-e"]) do
          {:ok, stdout} ->
            enabled_service_names =
              stdout
              |> String.split("\n")
              |> Enum.map(&String.trim/1)
              |> Enum.map(&Path.basename/1)
              |> Enum.into(%{}, &{&1, true})

            services =
              service_names
              |> Enum.map(fn name ->
                %{
                  name: name,
                  enabled: Map.has_key?(enabled_service_names, name),
                  running:
                    if Map.has_key?(enabled_service_names, name) do
                      service_is_running?(name)
                    else
                      nil
                    end,
                  description: "",
                  commands: [],
                  rcvars: []
                }
              end)

            {:ok, services}

          {:error, {stderr, _code}} ->
            Logger.error("list_services enabled, log: #{inspect(stderr)}")
            {:error, stderr}
        end

      {:error, {stderr, _code}} ->
        Logger.error("list_services, log: #{inspect(stderr)}")
        {:error, stderr}
    end
  end

  def start_service(name, args \\ []) do
    case service(name, "onestart", args) do
      {:ok, stdout} ->
        Logger.debug("start_service, log: #{inspect(stdout)}")
        Service.broadcast("start", {:ok, %{name: name, args: args, log: stdout}})
        {:ok, stdout}

      {:error, {stderr, _code}} ->
        Logger.error("start_service, log: #{inspect(stderr)}")
        Service.broadcast("start", {:error, %{name: name, args: args, log: stderr}})
        {:error, stderr}
    end
  end

  def stop_service(name, args \\ []) do
    case service(name, "onestop", args) do
      {:ok, stdout} ->
        Logger.debug("stop_service, log: #{inspect(stdout)}")
        Service.broadcast("stop", {:ok, %{name: name, args: args, log: stdout}})
        {:ok, stdout}

      {:error, {stderr, _code}} ->
        Logger.error("stop_service, log: #{inspect(stderr)}")
        Service.broadcast("stop", {:error, %{name: name, args: args, log: stderr}})
        {:error, stderr}
    end
  end

  def run_service_command(name, command, args \\ []) do
    case service(name, command, args) do
      {:ok, stdout} ->
        stdout = String.trim(stdout)

        stdout =
          if stdout == "" do
            "service #{name} #{command}"
          else
            stdout
          end

        Logger.debug("run_service_command, log: #{inspect(stdout)}")
        Service.broadcast("command", {:ok, %{name: name, command: command, args: args, log: stdout}})
        {:ok, stdout}

      {:error, {stderr, _code}} ->
        Logger.error("run_service_command, log: #{inspect(stderr)}")
        Service.broadcast("command", {:error, %{name: name, command: command, args: args, log: stderr}})
        {:error, stderr}
    end
  end

  def list_service_commands(name, args \\ []) do
    case service(name, "oneextracommands", args) do
      {:ok, stdout} ->
        service_names =
          stdout |> String.split(" ") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))

        Logger.debug("list_service_commands, commands: #{inspect(service_names)}")

        {:ok, service_names}

      {:error, {stderr, _code}} ->
        Logger.error("list_service_commands, log: #{inspect(stderr)}")
        {:error, stderr}
    end
  end

  def service_is_running?(name, args \\ []) do
    case service(name, "onestatus", args) do
      {:ok, stdout} ->
        Logger.debug("service_is_running, stdout: #{inspect(stdout)}")
        Service.broadcast("running", {:ok, %{name: name, args: args, log: stdout}})
        true

      {:error, {stderr, _code}} ->
        Logger.debug("service_is_running, stderr: #{inspect(stderr)}")
        Service.broadcast("stopped", {:error, %{name: name, args: args, log: stderr}})
        false
    end
  end

  defp service(name, action, args) do
    case execute(@service_bin, [name, action] ++ args, doas: true) do
      {:ok, stdout} -> {:ok, stdout}
      {:error, {stderr, code}} -> {:error, {stderr, code}}
    end
  end
end
