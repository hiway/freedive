defmodule FreediveWeb.HomeLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :refresh, 1_000)
      Phoenix.PubSub.subscribe(Freedive.PubSub, Freedive.Hostname.topic())
      Phoenix.PubSub.subscribe(Freedive.PubSub, Freedive.NodeTracker.topic())
    end

    node_name = Node.self() |> to_string()
    node_list = Node.list() |> Enum.map(&to_string/1)
    # {:ok, assign(socket, node_name: node_name, node_list: node_list, connect_status: nil)}

    {:ok,
     socket
     |> assign(node_name: node_name)
     |> assign(node_list: node_list)
     |> assign(connect_status: nil)
     |> assign(hostname: Freedive.Hostname.hostname())
     |> assign(nodes: Phoenix.Tracker.list(Freedive.NodeTracker, "nodes"))}
  end

  def render(assigns) do
    ~H"""
    <.navbar class="navbar">
      <.navbar_brand>
        <.navbar_item href="/">
          <.subtitle>
            Freedive
          </.subtitle>
        </.navbar_item>

        <.navbar_burger />
      </.navbar_brand>

      <.navbar_menu>
        <.navbar_start>
          <.navbar_dropdown label="System">
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Preferences
            </.link>
            <.navbar_divider />
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Backup
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Restore
            </.link>
            <.navbar_divider />
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Snapshot
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Rollback
            </.link>
            <.navbar_divider />
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Software Update
            </.link>
            <.navbar_divider />
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Reboot
            </.link>
          </.navbar_dropdown>

          <.navbar_dropdown label="Node">
            <.navbar_item href="#">
              <%= @node_name %>
            </.navbar_item>
            <%= for node <- @node_list do %>
              <.link patch={FreediveWeb.HomeLive} class="navbar-item">
                <%= node %>
              </.link>
            <% end %>
          </.navbar_dropdown>

          <.navbar_dropdown label="Network">
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Local
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Private
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Public
            </.link>
            <.navbar_divider />
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Domains
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Endpoints
            </.link>
          </.navbar_dropdown>

          <.navbar_dropdown label="Data">
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Local
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Remote
            </.link>
            <.navbar_divider />
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Share
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Sync
            </.link>
          </.navbar_dropdown>

          <.navbar_dropdown label="Compute">
          <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Apps
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Functions
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Services
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              Tasks
            </.link>
          </.navbar_dropdown>
        </.navbar_start>

        <.navbar_end>
          <.navbar_item href="/about">
            About
          </.navbar_item>
        </.navbar_end>
      </.navbar_menu>
    </.navbar>

    <%!-- <.box>
      <.grid class="is-col-min-12">
        <.cell>
          Tasks: 8 done, 3 doing, 4 todo
        </.cell>

        <.cell>
          Compute: <%= length(@nodes) %> nodes, 98% idle
        </.cell>

        <.cell>
          Memory: 26% ram, 3% swap
        </.cell>

        <.cell>
          Storage: 10.2 TB free, 4.8 TB used
        </.cell>

        <.cell>
          Network: 2.6 MB/s up, 1.2 MB/s down
        </.cell>

        <.cell>
          Federation: 17 instances
        </.cell>
      </.grid>
    </.box> --%>
    """
  end

  def handle_info(:refresh, socket) do
    Process.send_after(self(), :refresh, 1_000)
    {:noreply, assign(socket, node_list: Node.list() |> Enum.map(&to_string/1))}
  end

  def handle_info(%{hostname: hostname}, socket) do
    Logger.info("Hostname changed: #{hostname}")
    {:noreply, assign(socket, :hostname, hostname)}
  end

  def handle_info({:join, node, meta}, socket) do
    Logger.info("Node joined: #{inspect(node)} with meta #{inspect(meta)}")
    {:noreply, assign(socket, :nodes, Phoenix.Tracker.list(Freedive.NodeTracker, "nodes"))}
  end

  def handle_info({:leave, node, meta}, socket) do
    Logger.info("Node left: #{inspect(node)} with meta #{inspect(meta)}")
    {:noreply, socket}
  end
end
