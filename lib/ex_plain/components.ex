defmodule ExPlain.Components do
  @moduledoc """
  Builders for `ComponentInput` values used in thread and event creation.

  Components are the building blocks of thread messages and custom timeline
  entries. Each function returns a map shaped as `ComponentInput` in the
  Plain GraphQL schema.

  ## Example

      components = [
        ExPlain.Components.text("## Bug report"),
        ExPlain.Components.plain_text("Steps to reproduce:"),
        ExPlain.Components.plain_text("1. Visit /login\\n2. Enter credentials"),
        ExPlain.Components.divider(),
        ExPlain.Components.badge("High priority", color: :red)
      ]

  """

  @type component :: map()

  @doc "A markdown text block."
  @spec text(String.t()) :: component()
  def text(markdown_text) do
    %{componentText: %{text: markdown_text}}
  end

  @doc """
  A plain (non-markdown) text block.

  ## Options

    * `:size` - `:xs`, `:s`, `:m` (default), or `:l`
    * `:color` - `:normal` (default), `:muted`, `:success`, `:warning`, or `:error`
  """
  @spec plain_text(String.t(), keyword()) :: component()
  def plain_text(text, opts \\ []) do
    input =
      %{plainText: text}
      |> maybe_put(:plainTextSize, opts[:size])
      |> maybe_put(:plainTextColor, opts[:color] && encode_color(opts[:color]))

    %{componentPlainText: input}
  end

  @doc """
  A badge/pill label.

  ## Options

    * `:color` - `:green`, `:yellow`, `:red`, `:blue`, or `:grey`
  """
  @spec badge(String.t(), keyword()) :: component()
  def badge(label, opts \\ []) do
    input =
      %{label: label}
      |> maybe_put(:color, opts[:color] && encode_badge_color(opts[:color]))

    %{componentBadge: input}
  end

  @doc """
  A horizontal divider.

  ## Options

    * `:spacing_size` - `:xs`, `:s`, `:m` (default), `:l`, or `:xl`
  """
  @spec divider(keyword()) :: component()
  def divider(opts \\ []) do
    input =
      %{}
      |> maybe_put(
        :dividerSpacingSize,
        opts[:spacing_size] && String.upcase(to_string(opts[:spacing_size]))
      )

    %{componentDivider: input}
  end

  @doc "A vertical spacer."
  @spec spacer(atom()) :: component()
  def spacer(size \\ :m) do
    %{componentSpacer: %{spacerSize: String.upcase(to_string(size))}}
  end

  @doc "A link button."
  @spec link_button(String.t(), String.t()) :: component()
  def link_button(label, url) do
    %{componentLinkButton: %{linkButtonLabel: label, linkButtonUrl: url}}
  end

  @doc "A copy-to-clipboard button."
  @spec copy_button(String.t(), keyword()) :: component()
  def copy_button(value, opts \\ []) do
    input =
      %{copyButtonValue: value}
      |> maybe_put(:copyButtonTooltipLabel, opts[:tooltip])

    %{componentCopyButton: input}
  end

  @doc """
  A two-column row. Each cell should be a list of components.
  """
  @spec row(keyword()) :: component()
  def row(opts) do
    left = Keyword.get(opts, :main_content, [])
    right = Keyword.get(opts, :aside_content, [])

    %{
      componentRow: %{
        rowMainContent: left,
        rowAsideContent: right
      }
    }
  end

  @doc "A container for grouping components."
  @spec container(list(component())) :: component()
  def container(content) do
    %{componentContainer: %{containerContent: content}}
  end

  # ---------------------------------------------------------------------------

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp encode_color(:normal), do: "NORMAL"
  defp encode_color(:muted), do: "MUTED"
  defp encode_color(:success), do: "SUCCESS"
  defp encode_color(:warning), do: "WARNING"
  defp encode_color(:error), do: "ERROR"
  defp encode_color(other), do: String.upcase(to_string(other))

  defp encode_badge_color(:green), do: "GREEN"
  defp encode_badge_color(:yellow), do: "YELLOW"
  defp encode_badge_color(:red), do: "RED"
  defp encode_badge_color(:blue), do: "BLUE"
  defp encode_badge_color(:grey), do: "GREY"
  defp encode_badge_color(other), do: String.upcase(to_string(other))
end
