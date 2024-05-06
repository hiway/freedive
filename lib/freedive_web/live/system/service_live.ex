defmodule FreediveWeb.SystemServicesLive do
  use FreediveWeb, :live_view
  require Logger
  alias Freedive.Api.Service
  @filter_none "all"
  @filter_default "running"

  def mount(_params, _session, socket) do
    if connected?(socket) do
      Service.subscribe()
    end

    {:ok, services} = Service.list()
    filtered_services = filter(services, nil, @filter_default)

    socket =
      socket
      |> assign(query: nil)
      |> assign(filter: @filter_default)
      |> assign(filtered_services: filtered_services)
      |> assign(filtered_count: nil)
      |> assign(selected: nil)
      |> assign(selected_log: nil)
      |> assign(services: services)
      |> assign(show_details: false)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <nav class="panel">
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
            phx-hook="Search"
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
        <p class="panel-tabs">
          <.link phx-click="filter" phx-value-name="all" class={if @filter == "all", do: "is-active"}>
            All
          </.link>
          <.link
            phx-click="filter"
            phx-value-name="running"
            class={if @filter == "running", do: "is-active"}
          >
            Running
          </.link>
          <.link
            phx-click="filter"
            phx-value-name="enabled"
            class={if @filter == "enabled", do: "is-active"}
          >
            Enabled
          </.link>
        </p>

        <%= for service <- @filtered_services do %>
          <.panel_block
            icon="hero-puzzle-piece"
            phx-click="select"
            phx-value-name={service.name}
            class={
              if @selected != nil && Map.get(@selected, :name) == service.name,
                do: "has-background-info-light "
            }
          >
            <span class="mr-4 text-lg">
              <%= service.name %>
            </span>

            <%= if service.running do %>
              <span class="tag is-info">Running</span>
            <% else %>
              <span class="tag is-gray">Stopped</span>
            <% end %>

            <%= if service.enabled do %>
              <span class="tag is-success">Enabled</span>
            <% else %>
              <span class="tag is-gray">Disabled</span>
            <% end %>

            <%= if service.description != nil do %>
              <span class="text-gray-400 ml-4">
                <%= service.description |> String.capitalize() %>
              </span>
            <% end %>
          </.panel_block>
        <% end %>
        <%!--  --%>
      <% else %>
        <%!--  --%>
        <.panel_block
          icon="hero-arrow-left"
          phx-click="select"
          phx-value-name={@selected.name}
          class="has-background-gray-light text-lg"
        >
          Service: <%= @selected.name %>
        </.panel_block>

        <.panel_block
          icon={if @selected.running, do: "hero-check-circle", else: "hero-minus-circle"}
          class="text-lg"
        >
          <div>
            <span class="">
              <%= if @selected.running do %>
                <button class="button is-warning" phx-click="restart" phx-value-name={@selected.name}>
                  Restart
                </button>
                <button class="button is-danger" phx-click="stop" phx-value-name={@selected.name}>
                  Stop
                </button>
              <% else %>
                <button class="button is-success" phx-click="start" phx-value-name={@selected.name}>
                  Start
                </button>
              <% end %>

              <%= if @selected.commands != [] do %>
                <%= for command <- @selected.commands do %>
                  <button
                    class="button is-info"
                    phx-click="command"
                    phx-value-name={@selected.name}
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

  def handle_event("filter", %{"name" => filter}, socket) do
    Logger.debug("Filtering services: #{filter}")

    filtered_services = filter(socket.assigns.services, socket.assigns.query, filter)

    {:noreply,
     assign(socket,
       filter: filter,
       filtered_services: filtered_services,
       filtered_count: length(filtered_services),
       selected: nil,
       selected_log: nil,
       show_details: false
     )}
  end

  def handle_event("search", %{"value" => query}, socket) do
    Logger.debug("Searching for: #{query}")
    filtered_services = filter(socket.assigns.services, query, @filter_none)

    if length(filtered_services) == 1 do
      {:noreply,
       assign(socket,
         query: query,
         filter: @filter_none,
         filtered_services: filtered_services,
         filtered_count: length(filtered_services),
         selected: Service.service(hd(filtered_services).name),
         selected_log: [],
         show_details: true
       )}
    else
      {:noreply,
       assign(socket,
         query: query,
         filter: @filter_none,
         filtered_services: filtered_services,
         filtered_count: length(filtered_services),
         selected: nil,
         selected_log: nil,
         show_details: false
       )}
    end
  end

  def handle_event("select", %{"name" => service_name}, socket) do
    Logger.debug("Selected service: #{service_name}")

    if socket.assigns.selected && socket.assigns.selected.name == service_name do
      if socket.assigns.show_details do
        {:noreply, assign(socket, show_details: false)}
      else
        {:noreply, assign(socket, show_details: true)}
      end
    else
      {:noreply,
       assign(socket,
         selected: Service.service(service_name),
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
           selected: Service.service(service_name),
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
           selected: Service.service(service_name),
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
           selected: Service.service(service_name),
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
           selected: Service.service(service_name),
           selected_log: selected_log
         )}

      {:error, stderr} ->
        Logger.error("Service #{service_name} #{command} error: #{stderr}")
        selected_log = [{:error, stderr} | socket.assigns.selected_log]
        {:noreply, assign(socket, selected_log: selected_log)}
    end
  end

  def handle_info({"host:service:" <> event, {:error, log}}, socket) do
    # Logger.error("Received service event: #{inspect(event)} with log: #{inspect(log)}")
    service_name = Map.get(log, :name)
    services = socket.assigns.services

    case event do
      "stopped" ->
        services =
          Enum.map(services, fn service ->
            if service.name == service_name do
              Logger.warning("Service #{service_name} is not running")
              %{service | running: false}
            else
              service
            end
          end)

        {:noreply,
         assign(socket,
           services: services,
           filtered_services: filter(services, socket.assigns.query, socket.assigns.filter)
         )}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_info({"host:service:" <> event, {:ok, payload}}, socket) do
    # Logger.debug("Received service event: #{inspect(event)} with payload: #{inspect(payload)}")
    service_name = Map.get(payload, :name)
    services = socket.assigns.services

    case event do
      "running" ->
        services =
          Enum.map(services, fn service ->
            if service.name == service_name do
              Logger.warning("Service #{service_name} is running")
              %{service | running: true}
            else
              service
            end
          end)

        {:noreply,
         assign(socket,
           services: services,
           filtered_services: filter(services, socket.assigns.query, socket.assigns.filter)
         )}

      _ ->
        {:noreply, socket}
    end
  end

  defp filter(services, query, filter) do
    searched_services =
      case query do
        nil -> services
        "" -> services
        _ -> Enum.filter(services, &String.contains?(&1.name, query))
      end

    case filter do
      "all" ->
        searched_services

      "running" ->
        Enum.filter(searched_services, & &1.running)

      "enabled" ->
        Enum.filter(searched_services, & &1.enabled)
    end
  end
end
