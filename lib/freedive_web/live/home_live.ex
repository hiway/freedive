defmodule FreediveWeb.HomeLive do
  use FreediveWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :refresh, 1_000)
    end

    node_name = Node.self() |> to_string()
    node_list = Node.list() |> Enum.map(&to_string/1)
    {:ok, assign(socket, node_name: node_name, node_list: node_list, connect_status: nil)}
  end

  def render(assigns) do
    ~H"""
    <p>This node: <%= @node_name %></p>
    <p>Connected nodes:</p>
    <%= for node <- @node_list do %>
      <p><%= node %></p>
    <% end %>
    <hr />
    <form phx-submit="node_connect" phx-page-loading>
      <label for="node_name">Node name:</label>
      <input type="text" name="node_name" placeholder="node@hostname" />
      <button>Connect</button>
      <p if:{@connect_status}><%= @connect_status %></p>
    </form>
    """
  end

  def handle_event("node_connect", %{"node_name" => node_name}, socket) do
    case Node.connect(String.to_atom(node_name)) do
      true ->
        {:noreply,
         assign(socket,
           connect_status: "Connected",
           node_list: Node.list() |> Enum.map(&to_string/1)
         )}

      false ->
        {:noreply, assign(socket, connect_status: "Failed to connect to #{node_name}")}
    end
  end

  def handle_info(:refresh, socket) do
    Process.send_after(self(), :refresh, 1_000)
    {:noreply, assign(socket, node_list: Node.list() |> Enum.map(&to_string/1))}
  end
end
