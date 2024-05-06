defmodule Freedive.Api.Service.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    children = [
      Supervisor.child_spec({Freedive.Api.Service.CommandMonitor, opts},
        id: Freedive.Api.Service.CommandMonitor
      ),
      Supervisor.child_spec({Freedive.Api.Service.FilesystemMonitor, opts},
        id: Freedive.Api.Service.FilesystemMonitor
      ),
      Supervisor.child_spec({Freedive.Api.Service.Server, opts},
        id: Freedive.Api.Service.Server
      )
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
