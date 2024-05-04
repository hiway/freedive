defmodule FreediveWeb.Bulma do
  @moduledoc """
  Components for Bulma CSS.
  """
  use Phoenix.Component
  import FreediveWeb.CoreComponents

  @doc """
  Renders navbar.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def navbar(assigns) do
    ~H"""
    <nav class={["navbar", @class]} role="navigation" aria-label="main navigation">
      <%= render_slot(@inner_block) %>
    </nav>
    """
  end

  @doc """
  Renders navbar brand.
  """
  attr :href, :string, default: nil
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def navbar_brand(assigns) do
    ~H"""
    <div class="navbar-brand">
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders navbar burger.
  """
  attr :class, :string, default: nil

  def navbar_burger(assigns) do
    ~H"""
    <a
      role="button"
      class={["navbar-burger", @class]}
      aria-label="menu"
      aria-expanded="false"
      data-target="navbarMenu"
    >
      <span aria-hidden="true"></span>
      <span aria-hidden="true"></span>
      <span aria-hidden="true"></span>
      <span aria-hidden="true"></span>
    </a>
    """
  end

  @doc """
  Renders navbar menu.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def navbar_menu(assigns) do
    ~H"""
    <div id="navbarMenu" class={["navbar-menu", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders navbar start.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def navbar_start(assigns) do
    ~H"""
    <div class={["navbar-start", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders navbar end.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def navbar_end(assigns) do
    ~H"""
    <div class={["navbar-end", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders navbar item as <a> tag.
  """
  attr :href, :string, default: nil
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def navbar_item(assigns) do
    ~H"""
    <a href={@href} class={["navbar-item", @class]}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  @doc """
  Renders navbar item as <div>.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def navbar_item_div(assigns) do
    ~H"""
    <div class={["navbar-item", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders navbar link with dropdown.
  """
  attr :class, :string, default: nil
  attr :label, :string, required: true

  slot :inner_block, required: true

  def navbar_dropdown(assigns) do
    ~H"""
    <div class={["navbar-item has-dropdown is-hoverable", @class]}>
      <a class="navbar-link">
        <%= @label %>
      </a>

      <div class="navbar-dropdown">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders horizontal line to separate navbar items.
  """
  attr :class, :string, default: nil

  def navbar_divider(assigns) do
    ~H"""
    <hr class={["navbar-divider", @class]} />
    """
  end

  @doc """
  Renders title.
  """
  attr :class, :string, default: nil
  attr :level, :string, default: "3"

  slot :inner_block, required: true

  def title(assigns) do
    case(assigns.level) do
      "1" ->
        ~H"""
        <h1 class={["title is-1", @class]}>
          <%= render_slot(@inner_block) %>
        </h1>
        """

      "2" ->
        ~H"""
        <h2 class={["title is-2", @class]}>
          <%= render_slot(@inner_block) %>
        </h2>
        """

      "3" ->
        ~H"""
        <h3 class={["title is-3", @class]}>
          <%= render_slot(@inner_block) %>
        </h3>
        """

      "4" ->
        ~H"""
        <h4 class={["title is-4", @class]}>
          <%= render_slot(@inner_block) %>
        </h4>
        """

      "5" ->
        ~H"""
        <h5 class={["title is-5", @class]}>
          <%= render_slot(@inner_block) %>
        </h5>
        """

      "6" ->
        ~H"""
        <h6 class={["title is-6", @class]}>
          <%= render_slot(@inner_block) %>
        </h6>
        """
    end
  end

  @doc """
  Renders subtitle.
  """
  attr :class, :string, default: nil
  attr :level, :string, default: "5"

  slot :inner_block, required: true

  def subtitle(assigns) do
    case(assigns.level) do
      "1" ->
        ~H"""
        <h1 class={["subtitle is-1", @class]}>
          <%= render_slot(@inner_block) %>
        </h1>
        """

      "2" ->
        ~H"""
        <h2 class={["subtitle is-2", @class]}>
          <%= render_slot(@inner_block) %>
        </h2>
        """

      "3" ->
        ~H"""
        <h3 class={["subtitle is-3", @class]}>
          <%= render_slot(@inner_block) %>
        </h3>
        """

      "4" ->
        ~H"""
        <h4 class={["subtitle is-4", @class]}>
          <%= render_slot(@inner_block) %>
        </h4>
        """

      "5" ->
        ~H"""
        <h5 class={["subtitle is-5", @class]}>
          <%= render_slot(@inner_block) %>
        </h5>
        """

      "6" ->
        ~H"""
        <h6 class={["subtitle is-6", @class]}>
          <%= render_slot(@inner_block) %>
        </h6>
        """
    end
  end

  @doc """
  Renders fixed grid.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def fixed_grid(assigns) do
    ~H"""
    <div class={["fixed-grid", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders grid.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def grid(assigns) do
    ~H"""
    <div class={["grid", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders grid cell.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def cell(assigns) do
    ~H"""
    <div class={["cell", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders columns.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def columns(assigns) do
    ~H"""
    <div class={["columns", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders column.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def column(assigns) do
    ~H"""
    <div class={["column", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders section.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def section(assigns) do
    ~H"""
    <section class={["section", @class]}>
      <%= render_slot(@inner_block) %>
    </section>
    """
  end

  @doc """
  Renders box.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def box(assigns) do
    ~H"""
    <div class={["box", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders container.
  """
  attr :class, :string, default: nil

  slot :inner_block, required: true

  def container(assigns) do
    ~H"""
    <div class={["container", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end

  @doc """
  Renders panel.
  """
  attr :class, :string, default: nil
  attr :search, :string, default: nil

  slot :heading, required: true
  slot :tabs, required: false
  slot :inner_block, required: true

  def panel(assigns) do
    ~H"""
    <nav class={["panel", @class]}>
      <p class="panel-heading">
        <%= render_slot(@heading) %>
      </p>
      <%= if @search == "true" do %>
        <div class="panel-block">
          <p class="control has-icons-left">
            <input class="input" type="text" placeholder="Search" />
            <span class="icon is-left">
              <.icon name="hero-magnifying-glass" />
            </span>
          </p>
        </div>
      <% end %>
      <p class="panel-tabs">
        <%= render_slot(@tabs) %>
      </p>
      <%= render_slot(@inner_block) %>
    </nav>
    """
  end

  @doc """
  Renders panel block.
  """
  attr :class, :string, default: nil
  attr :icon, :string, required: true
  attr :icon_class, :string, default: nil
  attr :active, :string, default: "false"
  attr :rest, :global

  slot :inner_block, required: true

  def panel_block(assigns) do
    ~H"""
    <a class={["panel-block", append_is_active(@class, @active)]} {@rest}>
      <span class={["panel-icon mb-2", @icon_class]}>
        <.icon name={@icon} />
      </span>
      <span class="ml-2">
        <%= render_slot(@inner_block) %>
      </span>
    </a>
    """
  end

  defp append_is_active(class, active) do
    if active == "true" do
      "#{class} is-active"
    else
      class
    end
  end
end
