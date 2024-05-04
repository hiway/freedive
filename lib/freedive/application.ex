defmodule Freedive.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FreediveWeb.Telemetry,
      Freedive.Repo,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:freedive, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:freedive, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Freedive.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Freedive.Finch},
      {Cluster.Supervisor, [topologies(), [name: Freedive.ClusterSupervisor]]},
      # Start service supervisor
      {Freedive.Api.Service.Supervisor, [pubsub_server: Freedive.PubSub]},
      # Start node tracker
      {Freedive.NodeTracker, [name: Freedive.NodeTracker, pubsub_server: Freedive.PubSub]},
      # Start node supervisor
      {Freedive.NodeSupervisor, [pubsub: Freedive.PubSub]},
      # Start the Telemetry collector
      {Mobius, metrics: metrics(), persistence_dir: mobius_dir(), autosave_interval: 60},
      # Start to serve requests, typically the last entry
      FreediveWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Freedive.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    FreediveWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # By default, sqlite migrations are run when using a release
    System.get_env("RELEASE_NAME") != nil
  end

  def metrics() do
    [
      Telemetry.Metrics.last_value("vm.memory.total", unit: {:byte, :kilobyte})
    ]
  end

  defp mobius_dir() do
    Application.get_env(:freedive, :mobius_dir) || Application.app_dir(:freedive, "priv/mobius")
  end

  defp topologies() do
    nodes = System.get_env("NODES") || ""

    nodes =
      String.split(nodes, " ")
      |> Enum.map(&String.trim/1)
      |> Enum.reject(&(String.trim(&1) == ""))
      |> Enum.map(&String.to_atom/1)

    [
      epmd_cluster: [
        strategy: Elixir.Cluster.Strategy.Epmd,
        config: [
          timeout: 30_000,
          hosts: nodes
        ]
      ]
    ]
  end
end
