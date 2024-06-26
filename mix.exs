defmodule Freedive.MixProject do
  use Mix.Project

  def project do
    [
      app: :freedive,
      version: "0.2.0",
      description: "Dive into FreeBSD",
      homepage_url: "https://github.com/hiway/freedive",
      maintainer: "harshad@sharma.io",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      freebsd_pkg: freebsd_pkg()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Freedive.Application, []},
      extra_applications: [:logger, :runtime_tools, :os_mon]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sqlite3, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 0.20.2"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.2", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.2"},
      {:net_address, "~> 0.3.1"},
      {:libcluster, "~> 3.3"},
      {:opus, "~> 0.8.4"},
      {:mobius, "~> 0.6.1"},
      {:phx_config_util, "~> 0.1.0"},
      {:phx_tailwind_freebsd, "~> 0.2.1", runtime: Mix.env() == :dev},
      {:mix_freebsd_pkg, github: "hiway/mix_freebsd_pkg", runtime: Mix.env() == :dev}
    ]
  end

  defp freebsd_pkg do
    [
      service_commands: ["init"]
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: [
        "deps.get",
        "tailwind.install_freebsd",
        "ecto.setup",
        "assets.setup",
        "assets.build"
      ],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind freedive", "esbuild freedive"],
      "assets.deploy": [
        "tailwind freedive --minify",
        "esbuild freedive --minify",
        "phx.digest"
      ],
      "package.freebsd": ["compile", "assets.deploy", "release --overwrite", "freebsd.pkg"],
      prod: ["phx.server"]
    ]
  end

  def cli do
    [
      preferred_envs: ["package.freebsd": :prod, prod: :prod]
    ]
  end
end
