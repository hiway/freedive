defmodule Freedive.NodeSupervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    children = [
      Supervisor.child_spec({Freedive.Hostname.Server, opts}, id: :freedive_hostname),
      Supervisor.child_spec({Freedive.Node.Server, opts}, id: :freedive_node)
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
