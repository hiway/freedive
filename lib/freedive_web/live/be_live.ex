defmodule FreediveWeb.BELive do
  use Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(%{
       query: "",
       results: Freedive.Api.BE.list(),
       be_selected: nil
     })}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    {:noreply, assign(socket, results: search(query), query: query, be_selected: nil)}
  end

  @impl true
  def handle_event("search", %{"q" => query}, socket) do
    case search(query) do
      %{^query => vsn} ->
        {:noreply, redirect(socket, external: "https://freedive.local/#{query}/#{vsn}")}

      _ ->
        {:noreply,
         socket
         |> put_flash(:error, "No boot environments found matching \"#{query}\"")
         |> assign(results: %{}, query: query, be_selected: nil)}
    end
  end

  defp search(query) do
    for %{:name => name, :flags => flags} <- Freedive.Api.BE.list(),
        name = to_string(name),
        String.starts_with?(name, query),
        into: [],
        do: %{name: name, flags: flags}
  end

  @impl true
  def handle_event("be_select", %{"name" => name}, socket) do
    if socket.assigns[:be_selected] == name do
      {:noreply,
       socket
       |> assign(be_selected: nil)}
    else
      {:noreply,
       socket
       |> assign(be_selected: name)}
    end
  end

  def handle_event("be_default", %{"name" => name}, socket) do
    IO.puts(Freedive.Api.BE.set_default_be(name))
    {:noreply, assign(socket, results: Freedive.Api.BE.list())}
  end

  def handle_event("be_next", %{"name" => name}, socket) do
    if Freedive.Api.BE.is_next_boot?(name) do
      IO.puts(Freedive.Api.BE.unset_next_boot(name))
      {:noreply, assign(socket, results: Freedive.Api.BE.list())}
    else
      IO.puts(Freedive.Api.BE.set_next_boot(name))
      {:noreply, assign(socket, results: Freedive.Api.BE.list())}
    end
  end

  def handle_event("be_reboot", %{"name" => name}, socket) do
    IO.puts(Freedive.Api.BE.reboot_with_be(name))
    {:noreply, assign(socket, results: Freedive.Api.BE.list())}
  end

  def handle_event("be_create", %{"name" => name}, socket) do
    IO.puts(Freedive.Api.BE.create_be(name))
    {:noreply, assign(socket, results: Freedive.Api.BE.list())}
  end

  def render(assigns) do
    ~H"""
    <nav class="panel">
      <p class="panel-heading">
        Boot Environments
      </p>

      <div class="panel-block">
        <form phx-change="suggest" phx-submit="search" style="width: 100%">
          <input type="text" name="q" value={@query} placeholder="Search" autocomplete="off" class="input is-fullwidth"/>
        </form>
      </div>

      <%= if length(@results) > 0 do %>
        <%= for %{:name => name, :flags => flags} <- @results do %>
          <div class="panel-block is-active" phx-click="be_select" phx-value-name={name}
            style={if @be_selected == name do "background-color: #fafacc;" else "" end}>
            <span class="panel-icon" style="margin-right: 1.4rem;">
              <%= flags %>
            </span>
            <%= name %>
          <%= if @be_selected == name do %>
            <%= if String.contains?(flags, "N") do %>
              <%= if not String.contains?(flags, "R") do %>
                <button class="button is-danger" phx-click="be_default" phx-value-name={@be_selected} style="margin: 0 0.5rem;">
                  Make Default BE
                </button>
              <% end %>
            <% else %>
              <%= if not String.contains?(flags, "R") do %>
                <button class={if String.contains?(flags, "T") do "button is-success" else "button is-warning" end} phx-click="be_next" phx-value-name={@be_selected} style="margin: 0 0.5rem;">
                  Next
                </button>
              <% end %>
            <% end %>
              <button class="button is-danger" phx-click="be_reboot" phx-value-name={@be_selected} style="margin: 0 0.5rem;">
                Reboot
              </button>
          <% end %>
          </div>
        <% end %>
      <% else %>
        <div class="panel-block is-active">
          <button class="button is-danger" phx-click="be_create" phx-value-name={@query} style="margin: 0 0.5rem;">
            Create BE
          </button>
        </div>
      <% end %>
    </nav>
    <%#= live_render(@socket, FreediveWeb.FooterLive, id: "footer") %>
    """
  end
end
