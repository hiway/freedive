defmodule FreediveWeb.SystemServicesLive do
  use FreediveWeb, :live_view
  require Logger
  alias Freedive.Api.Service

  def mount(_params, _session, socket) do
    {:ok, services} = Service.list()

    socket =
      socket
      |> assign(services: services)
      |> assign(selected_name: nil)
      |> assign(selected_service: nil)
      |> assign(selected_log: nil)
      |> assign(query: nil)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true" query={@query}>
      <:heading>
        System Services
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Running</.link>
        <.link href="#">Enabled</.link>
      </:tabs>

      <%= for service <- filter(@services, @query) do %>
        <.panel_block
          icon="hero-puzzle-piece"
          phx-click="select"
          phx-value-name={service}
          class={if @selected_name == service, do: "has-background-gray-light"}
        >
          <span class="mr-4 text-lg">
            <%= service %>
          </span>

          <%= if @selected_name == service do %>
            <span>
              <%= if @selected_service.running do %>
                <button
                  class="button is-warning is-small"
                  phx-click="restart"
                  phx-value-name={service}
                >
                  Restart
                </button>
                <button class="button is-danger is-small" phx-click="stop" phx-value-name={service}>
                  Stop
                </button>
              <% else %>
                <button class="button is-success is-small" phx-click="start" phx-value-name={service}>
                  Start
                </button>
              <% end %>

              <%= if @selected_service.extra_commands != [] do %>
                <%= for command <- @selected_service.extra_commands do %>
                  <button
                    class="button is-info is-small"
                    phx-click="command"
                    phx-value-name={service}
                    phx-value-command={command}
                  >
                    <%= command %>
                  </button>
                <% end %>
              <% end %>

              <%= if @selected_log != nil and @selected_log != [] do %>
                <ul class="mt-4">
                  <%= for {status, log} <- @selected_log do %>
                    <%= for line <- log do %>
                      <%= if status == :error do %>
                        <li>
                          <span class="has-text-danger">◾</span>
                          <%= line %>
                        </li>
                      <% else %>
                        <li>
                          <span class="has-text-success">⚪</span>
                          <%= line %>
                        </li>
                      <% end %>
                    <% end %>
                  <% end %>
                </ul>
              <% end %>
            </span>
          <% end %>
        </.panel_block>
      <% end %>
    </.panel>
    """
  end

  def handle_event("search", %{"value" => query}, socket) do
    Logger.debug("Searching for: #{query}")
    {:noreply, assign(socket, query: query)}
  end

  def handle_event("start", %{"name" => service_name}, socket) do
    Logger.debug("Starting service: #{service_name}")

    case Service.start(service_name) do
      {:ok, stdout} ->
        Logger.debug("Service started: #{service_name}")
        selected_log = [{:ok, stdout} | socket.assigns.selected_log]

        {:noreply,
         assign(socket,
           selected_service: Service.service(service_name),
           selected_log: selected_log
         )}

      {:error, stderr} ->
        Logger.error("Service start error: #{stderr}")
        selected_log = [{:error, stderr} | socket.assigns.selected_log]
        {:noreply, assign(socket, selected_log: selected_log)}
    end
  end

  def handle_event("stop", %{"name" => service_name}, socket) do
    Logger.debug("Stopping service: #{service_name}")

    case Service.stop(service_name) do
      {:ok, stdout} ->
        Logger.debug("Service stopped: #{service_name}")
        selected_log = [{:ok, stdout} | socket.assigns.selected_log]

        {:noreply,
         assign(socket,
           selected_service: Service.service(service_name),
           selected_log: selected_log
         )}

      {:error, stderr} ->
        Logger.error("Service stop error: #{stderr}")
        selected_log = [{:error, stderr} | socket.assigns.selected_log]
        {:noreply, assign(socket, selected_log: selected_log)}
    end
  end

  def handle_event("restart", %{"name" => service_name}, socket) do
    Logger.debug("Restarting service: #{service_name}")

    case Service.restart(service_name) do
      {:ok, stdout} ->
        Logger.debug("Service restarted: #{service_name}")
        selected_log = [{:ok, stdout} | socket.assigns.selected_log]

        {:noreply,
         assign(socket,
           selected_service: Service.service(service_name),
           selected_log: selected_log
         )}

      {:error, stderr} ->
        Logger.error("Service restart error: #{stderr}")
        selected_log = [{:error, stderr} | socket.assigns.selected_log]
        {:noreply, assign(socket, selected_log: selected_log)}
    end
  end

  def handle_event("command", %{"command" => command, "name" => name}, socket) do
    Logger.debug("Executing command '#{command}' for service: #{name}")

    case Service.command(name, "one" <> command) do
      {:ok, stdout} ->
        Logger.debug("Command executed: #{command}")
        selected_log = [{:ok, stdout} | socket.assigns.selected_log]

        {:noreply,
         assign(socket,
           selected_service: Service.service(name),
           selected_log: selected_log
         )}

      {:error, stderr} ->
        Logger.error("Command error: #{stderr}")
        selected_log = [{:error, stderr} | socket.assigns.selected_log]
        {:noreply, assign(socket, selected_log: selected_log)}
    end
  end

  def handle_event("select", %{"name" => service_name}, socket) do
    Logger.debug("Selected service: #{service_name}")

    if socket.assigns.selected_name == service_name do
      {:noreply, assign(socket, selected_name: nil, selected_service: nil, selected_log: nil)}
    else
      {:noreply,
       assign(socket,
         selected_name: service_name,
         selected_service: Service.service(service_name),
         selected_log: []
       )}
    end
  end

  defp filter(services, query) do
    case query do
      nil -> services
      "" -> services
      _ -> Enum.filter(services, &String.contains?(&1, query))
    end
  end
end
