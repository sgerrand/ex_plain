defmodule ExPlain.ComponentsTest do
  use ExUnit.Case, async: true

  alias ExPlain.Components

  describe "text/1" do
    test "returns a componentText map" do
      assert %{componentText: %{text: "# Hello"}} = Components.text("# Hello")
    end
  end

  describe "plain_text/2" do
    test "returns a componentPlainText map with just text" do
      assert %{componentPlainText: %{plainText: "Hello"}} = Components.plain_text("Hello")
    end

    test "includes size when provided" do
      assert %{componentPlainText: %{plainText: "Hi", plainTextSize: :s}} =
               Components.plain_text("Hi", size: :s)
    end

    test "encodes all plain text colors" do
      for {color, expected} <- [
            normal: "NORMAL",
            muted: "MUTED",
            success: "SUCCESS",
            warning: "WARNING",
            error: "ERROR"
          ] do
        assert %{componentPlainText: %{plainTextColor: ^expected}} =
                 Components.plain_text("Hi", color: color)
      end
    end

    test "encodes unknown color via upcase" do
      assert %{componentPlainText: %{plainTextColor: "CUSTOM"}} =
               Components.plain_text("Hi", color: :custom)
    end
  end

  describe "badge/2" do
    test "returns a badge without color" do
      assert %{componentBadge: %{label: "New"}} = Components.badge("New")
    end

    test "includes color when provided" do
      assert %{componentBadge: %{label: "Hot", color: "RED"}} =
               Components.badge("Hot", color: :red)
    end

    test "encodes all badge colors" do
      for color <- [:green, :yellow, :red, :blue, :grey] do
        assert %{componentBadge: %{color: c}} = Components.badge("x", color: color)
        assert c == String.upcase(to_string(color))
      end
    end

    test "encodes unknown badge color via upcase" do
      assert %{componentBadge: %{color: "CUSTOM"}} = Components.badge("x", color: :custom)
    end
  end

  describe "divider/1" do
    test "returns a divider" do
      assert %{componentDivider: _} = Components.divider()
    end

    test "includes spacing_size when provided" do
      assert %{componentDivider: %{dividerSpacingSize: "XL"}} =
               Components.divider(spacing_size: :xl)
    end
  end

  describe "spacer/1" do
    test "defaults to medium size" do
      assert %{componentSpacer: %{spacerSize: "M"}} = Components.spacer()
    end

    test "accepts custom size" do
      assert %{componentSpacer: %{spacerSize: "L"}} = Components.spacer(:l)
    end
  end

  describe "link_button/2" do
    test "returns a link button" do
      assert %{componentLinkButton: %{linkButtonLabel: "Click", linkButtonUrl: "https://x.com"}} =
               Components.link_button("Click", "https://x.com")
    end
  end

  describe "copy_button/2" do
    test "returns a copy button" do
      assert %{componentCopyButton: %{copyButtonValue: "abc"}} = Components.copy_button("abc")
    end

    test "includes tooltip when provided" do
      assert %{componentCopyButton: %{copyButtonTooltipLabel: "Copy ID"}} =
               Components.copy_button("abc", tooltip: "Copy ID")
    end
  end

  describe "row/1" do
    test "returns a row with main and aside content" do
      main = [Components.text("Main")]
      aside = [Components.text("Aside")]

      assert %{componentRow: %{rowMainContent: ^main, rowAsideContent: ^aside}} =
               Components.row(main_content: main, aside_content: aside)
    end

    test "defaults to empty lists" do
      assert %{componentRow: %{rowMainContent: [], rowAsideContent: []}} = Components.row([])
    end
  end

  describe "container/1" do
    test "wraps content" do
      content = [Components.text("Hello")]

      assert %{componentContainer: %{containerContent: ^content}} =
               Components.container(content)
    end
  end
end
