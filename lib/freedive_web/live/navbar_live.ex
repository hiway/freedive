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
          <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-adjustments-horizontal" class="mr-3" /> Preferences
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-shield-check" class="mr-3" /> Secrets
            </.link>
            <.navbar_divider />
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-folder-arrow-down" class="mr-3" /> Backup
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-folder-open" class="mr-3" /> Restore
            </.link>
            <.navbar_divider />
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-archive-box-arrow-down" class="mr-3" /> Snapshot
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-arrow-uturn-up" class="mr-3" /> Rollback
            </.link>
            <.navbar_divider />
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-cloud-arrow-down" class="mr-3" /> Software Update
            </.link>
          </.navbar_dropdown>

          <.navbar_dropdown label="Node">
            <.navbar_item href="#">
              <.icon name="hero-map-pin" class="mr-3" />
              <%= @node_name %>
            </.navbar_item>
            <.navbar_divider />

            <%= for node <- @node_list do %>
              <.link patch={FreediveWeb.HomeLive} class="navbar-item">
                <.icon name="hero-globe-alt" class="mr-3" />
                <%= node %>
              </.link>
            <% end %>
          </.navbar_dropdown>

          <.navbar_dropdown label="Network">
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-wifi" class="mr-3" /> Local
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-cube-transparent" class="mr-3" /> Private
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-globe-alt" class="mr-3" /> Public
            </.link>
            <.navbar_divider />
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-tag" class="mr-3" /> Domains
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-arrows-up-down" class="mr-3" /> Endpoints
            </.link>
          </.navbar_dropdown>

          <.navbar_dropdown label="Data">
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-server-stack" class="mr-3" /> Local
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-cloud" class="mr-3" /> Remote
            </.link>
            <.navbar_divider />
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-share" class="mr-3" /> Share
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-arrow-path-rounded-square" class="mr-3" /> Sync
            </.link>
          </.navbar_dropdown>

          <.navbar_dropdown label="Compute">
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-rocket-launch" class="mr-3" /> Apps
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-code-bracket" class="mr-3" /> Functions
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-puzzle-piece" class="mr-3" /> Services
            </.link>
            <.link patch={FreediveWeb.HomeLive} class="navbar-item">
              <.icon name="hero-squares-2x2" class="mr-3" /> Tasks
            </.link>
          </.navbar_dropdown>
        </.navbar_start>

        <.navbar_end>
          <.navbar_dropdown label="Notifications" class="is-right">
          <.navbar_item href="#">
              <.icon name="hero-bell-alert" class="mr-3" /> Alerts
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
