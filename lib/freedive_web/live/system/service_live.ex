defmodule FreediveWeb.SystemServicesLive do
  use FreediveWeb, :live_view
  require Logger
  alias Freedive.Api.Service

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Service.subscribe()
    end

    {:ok, services} = Service.list()

    socket =
      socket
      |> assign(query: nil)
      |> assign(filtered_services: services)
      |> assign(filtered_count: nil)
      |> assign(selected_name: nil)
      |> assign(selected_service: nil)
      |> assign(selected_log: nil)
      |> assign(services: services)
      |> assign(show_details: false)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <nav class="panel" class={if @selected_name != nil, do: "hidden"}>
      <p class="panel-heading">
        System Services
      </p>

      <div class="panel-block">
        <p class="control has-icons-left">
          <input
            id="search"
            class="input"
            type="text"
            placeholder="Search"
            value={@query}
            phx-keyup="search"
            phx-debounce="300"
            autofocus="true"
          />
          <span class="icon is-left">
            <.icon name="hero-magnifying-glass" />
          </span>
        </p>
      </div>

      <%= if @show_details == false do %>
        <%= if @filtered_count == nil or @filtered_count > 1 do %>
          <p class="panel-tabs">
            <.link href="#" class="is-active">All</.link>
            <.link href="#">Running</.link>
            <.link href="#">Enabled</.link>
          </p>
        <% end %>

        <%= for service <- @filtered_services do %>
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
              <%= if @selected_service.running do %>
                <span class="tag is-success">Running</span>
              <% else %>
                <span class="tag is-danger">Stopped</span>
              <% end %>
            <% end %>
          </.panel_block>
        <% end %>
      <% else %>
        <.panel_block
          icon="hero-arrow-left"
          phx-click="select"
          phx-value-name={@selected_name}
          class="has-background-gray-light text-lg"
        >
          Service: <%= @selected_name %>
        </.panel_block>

        <.panel_block
          icon={if @selected_service.running, do: "hero-check-circle", else: "hero-minus-circle"}
          class="text-lg"
        >
          <div>
            <span class="">
              <%= if @selected_service.running do %>
                <button class="button is-warning" phx-click="restart" phx-value-name={@selected_name}>
                  Restart
                </button>
                <button class="button is-danger" phx-click="stop" phx-value-name={@selected_name}>
                  Stop
                </button>
              <% else %>
                <button class="button is-success" phx-click="start" phx-value-name={@selected_name}>
                  Start
                </button>
              <% end %>

              <%= if @selected_service.commands != [] do %>
                <%= for command <- @selected_service.commands do %>
                  <button
                    class="button is-info"
                    phx-click="command"
                    phx-value-name={@selected_name}
                    phx-value-command={command}
                  >
                    <%= command %>
                  </button>
                <% end %>
              <% end %>
            </span>
          </div>
        </.panel_block>

        <%= if @selected_log != nil and @selected_log != [] do %>
          <.panel_block icon="hero-newspaper" class="text-lg">
            <ul>
              <%= for {status, log} <- @selected_log do %>
                <%= for line <- log do %>
                  <%= if status == :error do %>
                    <li>
                      <span class="has-text-danger">❌</span>
                      <%= line %>
                    </li>
                  <% else %>
                    <li>
                      <span class="has-text-success">✅</span>
                      <%= line %>
                    </li>
                  <% end %>
                <% end %>
              <% end %>
            </ul>
          </.panel_block>
        <% end %>
      <% end %>
    </nav>
    """
  end

  def handle_event("search", %{"value" => query}, socket) do
    Logger.debug("Searching for: #{query}")
    filtered_services = filter(socket.assigns.services, query)

    if length(filtered_services) == 1 do
      {:noreply,
       assign(socket,
         query: query,
         filtered_services: filtered_services,
         selected_name: hd(filtered_services),
         selected_service: Service.service(hd(filtered_services)),
         selected_log: [],
         filtered_count: length(filtered_services),
         show_details: true
       )}
    else
      {:noreply,
       assign(socket,
         query: query,
         filtered_services: filtered_services,
         selected_name: nil,
         selected_service: nil,
         selected_log: nil,
         filtered_count: length(filtered_services),
         show_details: false
       )}
    end
  end

  def handle_event("select", %{"name" => service_name}, socket) do
    Logger.debug("Selected service: #{service_name}")

    if socket.assigns.selected_name == service_name do
      if socket.assigns.show_details do
        {:noreply, assign(socket, show_details: false)}
      else
        {:noreply, assign(socket, show_details: true)}
      end
    else
      {:noreply,
       assign(socket,
         selected_name: service_name,
         selected_service: Service.service(service_name),
         selected_log: []
       )}
    end
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
        Logger.error("Service #{service_name} start error: #{stderr}")
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
        Logger.error("Service #{service_name} stop error: #{stderr}")
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
        Logger.error("Service #{service_name} restart error: #{stderr}")
        selected_log = [{:error, stderr} | socket.assigns.selected_log]
        {:noreply, assign(socket, selected_log: selected_log)}
    end
  end

  def handle_event("command", %{"command" => command, "name" => service_name}, socket) do
    Logger.debug("Executing command '#{command}' for service: #{service_name}")

    case Service.run_command(service_name, "one" <> command) do
      {:ok, stdout} ->
        selected_log = [{:ok, stdout} | socket.assigns.selected_log]

        {:noreply,
         assign(socket,
           selected_service: Service.service(service_name),
           selected_log: selected_log
         )}

      {:error, stderr} ->
        Logger.error("Service #{service_name} #{command} error: #{stderr}")
        selected_log = [{:error, stderr} | socket.assigns.selected_log]
        {:noreply, assign(socket, selected_log: selected_log)}
    end
  end

  def handle_info({"host:service:" <> event, payload}, socket) do
    Logger.debug("Received service event: #{inspect(event)} with payload: #{inspect(payload)}")
    {:noreply, socket}
  end

  defp filter(services, query) do
    case query do
      nil -> services
      "" -> services
      _ -> Enum.filter(services, &String.contains?(&1, query))
    end
  end
end
