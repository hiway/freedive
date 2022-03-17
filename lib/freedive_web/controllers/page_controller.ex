defmodule FreediveWeb.PageController do
  use FreediveWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
