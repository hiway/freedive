defmodule FreediveWeb.NavbarLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :refresh, 1_000)
    end

    node_name = Node.self() |> to_string()
    node_list = Node.list() |> Enum.map(&to_string/1)

    {:ok,
     socket
     |> assign(node_name: node_name)
     |> assign(node_list: node_list)
     |> assign(connect_status: nil)}
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
            <.link href="/system/preferences" class="navbar-item">
              <.icon name="hero-adjustments-horizontal" class="mr-3" /> Preferences
            </.link>

            <.navbar_divider />
            <.link href="/system/secrets" class="navbar-item">
              <.icon name="hero-finger-print" class="mr-3" /> Secrets
            </.link>
            <.link href="/system/security" class="navbar-item">
              <.icon name="hero-shield-check" class="mr-3" /> Security
            </.link>

            <.navbar_divider />
            <.link href="/system/backups" class="navbar-item">
              <.icon name="hero-folder-arrow-down" class="mr-3" /> Backups
            </.link>

            <.navbar_divider />
            <.link href="/system/updates" class="navbar-item">
              <.icon name="hero-cloud-arrow-down" class="mr-3" /> Software Update
            </.link>
          </.navbar_dropdown>

          <.navbar_dropdown label="Cluster">
            <.navbar_item href="#">
              <.icon name="hero-map-pin" class="mr-3" />
              <%= @node_name %>
            </.navbar_item>

            <%= if length(@node_list) > 0 do %>
              <.navbar_divider />
            <% end %>

            <%= for node <- @node_list do %>
              <.link patch={FreediveWeb.HomeLive} class="navbar-item">
                <.icon name="hero-globe-alt" class="mr-3" />
                <%= node %>
              </.link>
            <% end %>

            <.navbar_divider />

            <.navbar_item href="/cluster/nodes">
              <.icon name="hero-pencil-square" class="mr-3" /> Manage Nodes
            </.navbar_item>
          </.navbar_dropdown>

          <.navbar_dropdown label="Network">
            <.link href="/network/local" class="navbar-item">
              <.icon name="hero-wifi" class="mr-3" /> Local
            </.link>
            <.link href="/network/private" class="navbar-item">
              <.icon name="hero-lock-closed" class="mr-3" /> Private
            </.link>
            <.link href="/network/public" class="navbar-item">
              <.icon name="hero-globe-alt" class="mr-3" /> Public
            </.link>
            <.navbar_divider />
            <.link href="/network/domains" class="navbar-item">
              <.icon name="hero-tag" class="mr-3" /> Domains
            </.link>
            <.link href="/network/endpoints" class="navbar-item">
              <.icon name="hero-arrows-up-down" class="mr-3" /> Endpoints
            </.link>
          </.navbar_dropdown>

          <.navbar_dropdown label="Data">
            <.link href="/data/local" class="navbar-item">
              <.icon name="hero-server" class="mr-3" /> Local
            </.link>
            <.link href="/data/remote" class="navbar-item">
              <.icon name="hero-cloud" class="mr-3" /> Remote
            </.link>
            <.navbar_divider />
            <.link href="/data/share" class="navbar-item">
              <.icon name="hero-share" class="mr-3" /> Share
            </.link>
            <.link href="/data/sync" class="navbar-item">
              <.icon name="hero-arrow-path-rounded-square" class="mr-3" /> Sync
            </.link>
          </.navbar_dropdown>

          <.navbar_dropdown label="Compute">
            <.link href="/compute/apps" class="navbar-item">
              <.icon name="hero-rocket-launch" class="mr-3" /> Apps
            </.link>
            <.link href="/compute/services" class="navbar-item">
              <.icon name="hero-puzzle-piece" class="mr-3" /> Services
            </.link>

            <.navbar_divider />
            <.link href="/compute/functions" class="navbar-item">
              <.icon name="hero-code-bracket" class="mr-3" /> Functions
            </.link>
            <.link href="/compute/tasks" class="navbar-item">
              <.icon name="hero-squares-2x2" class="mr-3" /> Tasks
            </.link>
          </.navbar_dropdown>
        </.navbar_start>

        <.navbar_end>
          <.navbar_dropdown label="Notifications" class="is-right">
            <.navbar_item href="#">
              <.icon name="hero-bell-alert" class="mr-3" /> Alerts
            </.navbar_item>
            <.navbar_item href="#">
              <.icon name="hero-newspaper" class="mr-3" /> Logs
            </.navbar_item>
            <.navbar_item href="#">
              <.icon name="hero-presentation-chart-bar" class="mr-3" /> Metrics
            </.navbar_item>

            <.navbar_divider />
            <.navbar_item href="#">
              <.icon name="hero-arrows-pointing-out" class="mr-3" /> Channels
            </.navbar_item>
          </.navbar_dropdown>

          <.navbar_dropdown label="Account" class="is-right">
            <.navbar_item href="#">
              <.icon name="hero-adjustments-vertical" class="mr-3" /> Preferences
            </.navbar_item>

            <.navbar_divider />
            <.navbar_item href="#">
              <.icon name="hero-arrow-left-start-on-rectangle" class="mr-3" /> Log out
            </.navbar_item>
          </.navbar_dropdown>

          <.navbar_item href="#" class="mr-4">
            user@example.com
          </.navbar_item>
        </.navbar_end>
      </.navbar_menu>
    </.navbar>
    """
  end

  def handle_info(:refresh, socket) do
    Process.send_after(self(), :refresh, 1_000)
    {:noreply, assign(socket, node_list: Node.list() |> Enum.map(&to_string/1))}
  end
end
