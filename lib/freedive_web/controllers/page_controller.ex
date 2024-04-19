defmodule FreediveWeb.PageController do
  use FreediveWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    node_name = Node.self() |> to_string()
    render(conn, :home, layout: false, node_name: node_name)
  end
end
