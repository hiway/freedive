defmodule Freedive.Api.Service.Cli do
  @moduledoc """
  Wrapper around `service` command on FreeBSD.
  """
  require Logger
  import Freedive

  @service_bin "/usr/sbin/service"

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

        {:ok, service_names}

      {:error, {stderr, _code}} ->
        {:error, stderr}
    end
  end

  def start_service(name, args \\ []) do
    case service(name, "onestart", args) do
      {:ok, stdout} -> {:ok, stdout}
      {:error, {stderr, _code}} -> {:error, stderr}
    end
  end

  def stop_service(name, args \\ []) do
    case service(name, "onestop", args) do
      {:ok, stdout} -> {:ok, stdout}
      {:error, {stderr, _code}} -> {:error, stderr}
    end
  end

  def service_extra_commands(name, args \\ []) do
    case service(name, "oneextracommands", args) do
      {:ok, stdout} ->
        {:ok, stdout |> String.split(" ") |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))}

      {:error, {stderr, _code}} ->
        {:error, stderr}
    end
  end

  def service_is_running?(name, args \\ []) do
    case service(name, "onestatus", args) do
      {:ok, stdout} ->
        Logger.debug("service_is_running, stdout: #{inspect(stdout)}")
        true

      {:error, {stderr, _code}} ->
        if String.contains?(stderr, "is not running") do
          Logger.debug("service_is_running, stderr: #{inspect(stderr)}")
          false
        else
          Logger.error("service_is_running, stderr: #{inspect(stderr)}")
          false
        end
    end
  end

  def service(name, action, args) do
    case execute(@service_bin, [name, action] ++ args, doas: true) do
      {:ok, stdout} -> {:ok, stdout}
      {:error, {stderr, code}} -> {:error, {stderr, code}}
    end
  end
end
