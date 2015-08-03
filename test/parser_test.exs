defmodule ParserTest do
  use ExUnit.Case

  alias SlimFast.Parser

  test "parses simple nesting" do
    parsed = ["#id.class", "\tp", "\t| Hello World"] |> Parser.parse_lines
    assert parsed == [{0, {:div, attributes: [class: ["class"], id: "id"], children: []}}, {2, {:p, attributes: [], children: []}}, {2, "Hello World"}]

    parsed = ["#id.class","\tp Hello World"] |> Parser.parse_lines
    assert parsed == [{0, {:div, attributes: [class: ["class"], id: "id"], children: []}}, {2, {:p, attributes: [], children: ["Hello World"]}}]
  end

  test "parses attributes" do
    {_, {:meta, opts}} = "meta name=variable content=\"one two\""
                         |> Parser.parse_line

    assert opts[:attributes] == [content: "one two", name: {:eex, content: "variable", inline: true}]
  end

  test "parses attributes and inline children" do
    {_, {:div, opts}} = "div id=\"id\" text content"
                        |> Parser.parse_line

    assert opts[:attributes] == [id: "id"]
    assert opts[:children] == ["text content"]

    {_, {:div, opts}} = "div id=\"id\" = elixir_func"
                        |> Parser.parse_line

    assert opts[:children] == [{:eex, content: "elixir_func", inline: true}]
  end

  test "parses doctype" do
    {_, {:doctype, doc_string}} = "doctype html"
                         |> Parser.parse_line

    assert doc_string == "<!DOCTYPE html>"
  end

  test "parses final newline properly" do
    parsed = ["#id.class", "\tp", "\t| Hello World", ""] |> Parser.parse_lines
    assert parsed == [{0, {:div, attributes: [class: ["class"], id: "id"], children: []}}, {2, {:p, attributes: [], children: []}}, {2, "Hello World"}]
  end
end
