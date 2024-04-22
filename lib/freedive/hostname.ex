defmodule Freedive.Hostname do
  @moduledoc """
  Get and set hostname of host or jail.

  Example:

      iex> Freedive.Hostname.get_hostname!(jail: "testjail")
      "testjail"

      iex> Freedive.Hostname.get_hostname(jail: "testjail")
      {:ok, "testjail"}

      iex> Freedive.Hostname.set_hostname!("testjail", jail: "testjail")
      "testjail"

      iex> Freedive.Hostname.set_hostname("testjail", jail: "testjail")
      {:ok, "testjail"}
  """
  import Freedive
  alias Freedive.Hostname

  def topic() do
    Hostname.Server.topic()
  end

  def hostname() do
    Hostname.Server.hostname()
  end

  def get_hostname!(opts \\ []), do: get_hostname(opts) |> raise_on_error()

  def get_hostname(opts \\ []) do
    Hostname.GetHostname.call(%{opts: opts})
  end

  def set_hostname!(hostname, opts \\ []), do: set_hostname(hostname, opts) |> raise_on_error()

  def set_hostname(hostname, opts \\ []) do
    Hostname.SetHostname.call(%{hostname: hostname, opts: opts})
  end
end

defmodule Freedive.Hostname.GetHostname do
  use Opus.Pipeline
  import Freedive

  step(:get_hostname)

  def get_hostname(%{opts: opts}) do
    execute!("hostname", [], opts)
  end
end

defmodule Freedive.Hostname.SetHostname do
  use Opus.Pipeline
  import Freedive

  check(:hostname_is_valid_string)
  check(:hostname_is_valid_length)
  check(:hostname_has_valid_chars)
  step(:set_hostname_live, if: :hostname_changed?)
  step(:set_hostname_sysrc, if: :hostname_changed?)
  link(Freedive.Hostname.GetHostname)

  def hostname_is_valid_string(%{hostname: hostname, opts: _}) do
    String.valid?(hostname)
  end

  def hostname_is_valid_length(%{hostname: hostname, opts: _}) do
    String.length(hostname) <= hostname_max()
  end

  defp hostname_max() do
    execute!("getconf", ["HOST_NAME_MAX"]) |> String.to_integer()
  end

  def hostname_has_valid_chars(%{hostname: hostname, opts: _}) do
    Regex.match?(~r/^[a-z0-9-.]+$/, hostname)
  end

  def hostname_changed?(%{hostname: hostname, opts: opts}) do
    {:ok, current_hostname} = Freedive.Hostname.GetHostname.call(%{opts: opts})
    current_hostname != hostname
  end

  def set_hostname_live(%{hostname: hostname, opts: opts} = pipeline) do
    execute!("hostname", [hostname], opts)
    pipeline
  end

  def set_hostname_sysrc(%{hostname: hostname, opts: opts} = pipeline) do
    execute!("sysrc", ["hostname=#{hostname}"], opts)
    pipeline
  end
end

defmodule Freedive.Hostname.Server do
  @moduledoc """
  GenServer to monitor and broadcast hostname changes.
  """
  use GenServer
  require Logger

  @refresh 30_000
  @jitter 1_000
  @topic "freedive:hostname"

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def topic() do
    @topic
  end

  def hostname() do
    GenServer.call(__MODULE__, :hostname)
  end

  def get_refresh_interval() do
    GenServer.call(__MODULE__, :get_refresh_interval)
  end

  def set_refresh_interval(interval) do
    GenServer.cast(__MODULE__, {:set_refresh_interval, interval})
  end

  @impl true
  def init(opts) do
    if opts[:pubsub] == nil do
      raise "Freedive.Hostname: PubSub not configured"
    end

    state = %{
      hostname: "unknown",
      pubsub: opts[:pubsub],
      topic: opts[:topic] || @topic,
      refresh: opts[:refresh] || @refresh,
      jitter: opts[:jitter] || @jitter
    }

    Process.send_after(self(), :refresh, 0)
    Logger.debug("Freedive.Hostname started")
    {:ok, state}
  end

  @impl true
  def handle_call(:hostname, _from, state) do
    {:reply, state[:hostname], state}
  end

  @impl true
  def handle_call(:get_refresh_interval, _from, state) do
    {:reply, state[:refresh], state}
  end

  @impl true
  def handle_cast({:set_refresh_interval, interval}, state) do
    {:noreply, Map.merge(state, %{refresh: interval})}
  end

  @impl true
  def handle_info(:refresh, state) do
    current_hostname = Freedive.Hostname.get_hostname!()
    previous_hostname = state[:hostname]

    case current_hostname == previous_hostname do
      true ->
        # Logger.debug("Freedive.Hostname: No change")
        nil

      false ->
        Logger.debug("Freedive.Hostname: #{previous_hostname} -> #{current_hostname}")

        Phoenix.PubSub.broadcast(
          state[:pubsub],
          state[:topic],
          %{hostname: current_hostname}
        )
    end

    state = Map.put(state, :hostname, current_hostname)

    Process.send_after(
      self(),
      :refresh,
      state[:refresh] + :rand.uniform(state[:jitter])
    )

    {:noreply, state}
  end
end
