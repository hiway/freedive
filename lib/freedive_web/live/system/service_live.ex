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

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        System Services
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Running</.link>
        <.link href="#">Enabled</.link>
      </:tabs>

      <%= for service <- @services do %>
        <.panel_block icon="hero-puzzle-piece" phx-click="select" phx-value-name={service}>
          <span class="mr-4 text-lg">
            <%= service %>
          </span>
          <%= if @selected_name == service do %>
            <span>
              <%= if @selected_service.running do %>
                <button class="button is-danger is-small" phx-click="stop" phx-value-name={service}>
                  Stop
                </button>
              <% else %>
                <button class="button is-success is-small" phx-click="start" phx-value-name={service}>
                  Start
                </button>
              <% end %>
            </span>
          <% end %>
        </.panel_block>
      <% end %>
    </.panel>
    """
  end

  def handle_event("start", %{"name" => service_name}, socket) do
    Logger.debug("Starting service: #{service_name}")

    case Service.start(service_name) do
      {:ok, _stdout} ->
        Logger.debug("Service started: #{service_name}")

        selected_service = %{name: service_name, running: Service.is_running?(service_name)}
        {:noreply, assign(socket, selected_service: selected_service)}

      {:error, stderr} ->
        Logger.error("Service start error: #{stderr}")
        {:noreply, socket}
    end
  end

  def handle_event("stop", %{"name" => service_name}, socket) do
    Logger.debug("Stopping service: #{service_name}")

    case Service.stop(service_name) do
      {:ok, _stdout} ->
        Logger.debug("Service stopped: #{service_name}")

        selected_service = %{name: service_name, running: Service.is_running?(service_name)}
        {:noreply, assign(socket, selected_service: selected_service)}

      {:error, stderr} ->
        Logger.error("Service stop error: #{stderr}")
        {:noreply, socket}
    end
  end

  def handle_event("select", %{"name" => service_name}, socket) do
    Logger.debug("Selected service: #{service_name}")

    if socket.assigns.selected_name == service_name do
      {:noreply, assign(socket, selected_name: nil, selected_service: nil)}
    else
      {:noreply,
       assign(socket,
         selected_name: service_name,
         selected_service: %{name: service_name, running: Service.is_running?(service_name)}
       )}
    end
  end
end
