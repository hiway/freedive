defmodule FreediveWeb.SystemMetricsLive do
  use FreediveWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.panel search="true">
      <:heading>
        Metrics
      </:heading>

      <:tabs>
        <.link href="#" class="is-active">All</.link>
        <.link href="#">Errors</.link>
        <.link href="#">Warnings</.link>
      </:tabs>

      <.panel_block icon="hero-chart-bar">
        All available metrics will be listed here
      </.panel_block>

      <.panel_block icon="hero-chart-pie">
        They can be inspected by clicking on the metric name
      </.panel_block>

      <.panel_block icon="hero-chart-bar-square">
        Metrics can be added to or removed from the home page,
        where they will be displayed in a grid
      </.panel_block>
    </.panel>
    """
  end
end
