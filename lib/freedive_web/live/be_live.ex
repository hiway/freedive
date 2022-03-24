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
end
