defmodule FreediveWeb.PageController do
  use FreediveWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    node_name = Node.self() |> to_string()
    node_list = Node.list() |> Enum.map(&to_string/1)
    render(conn, :home, layout: false, node_name: node_name, node_list: node_list)
  end
end
