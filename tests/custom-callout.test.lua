-- custom-callout tests. Run from the repo root: quarto pandoc lua path/to/qtest.lua
local t = require("qtest")

-- Regression: 3-digit hex colors such as "#F00" gave no header background.
t.test("html: a defined type becomes a callout titled by its name, colored by the page's stylesheet", function()
  local r = t.render("callouts.qmd", "html")
  r:succeeded()
  t.contains(r.text, '<div class="callout callout-style-default callout-todo callout-titled">')
  t.contains(r.text, '<span class="screen-reader-only">Todo</span>Todo')
  t.in_order(r.text, { "<style>", "div.callout-todo.callout {\n  border-left-color: #F00;",
    "div.callout-todo.callout-style-default .callout-header {\n  background-color: rgba(255, 0, 0, 0.13);" })
  t.contains(r.text, "div.callout-repo.callout-style-default .callout-header {\n  background-color: rgb(from navy r g b / 13%);")
end)

-- Regressions: FontAwesome icons showed as placeholder boxes (the font
-- wasn't bundled) and in italics; brand icons such as fa-github didn't
-- render; an icon-symbol without a color wasn't styled.
t.test("html: icon-symbol takes an emoji, a FontAwesome icon or a brand icon, and bundles the font", function()
  local r = t.render("callouts.qmd", "html")
  t.contains(r.text, "div.callout-idea.callout-titled .callout-icon::before {\n  content: '💡';")
  t.contains(r.text, "div.callout-star.callout-titled .callout-icon::before {\n  font-family: 'Font Awesome 7 Free';\n  font-weight: 900;\n  font-style: normal;\n  content: '\\f005' !important;")
  t.contains(r.text, "div.callout-repo.callout-titled .callout-icon::before {\n  font-family: 'Font Awesome 7 Brands';\n  font-weight: 400;")
  t.contains(r.text, 'href="callouts_files/libs/quarto-contrib/fontawesome-7-free-7.2.0/fontawesome.css"')
end)

-- Regression: icon: false in a definition was ignored.
t.test("html: a definition's title, icon: false, appearance and collapse reach the callout", function()
  local r = t.render("callouts.qmd", "html")
  t.contains(r.text, '<div class="callout callout-style-simple callout-quiet no-icon callout-titled">')
  t.contains(r.text, '<span class="screen-reader-only">Quiet</span>Quiet one')
  t.in_order(r.text, { "callout-quiet no-icon", 'data-bs-toggle="collapse"', "Quiet body." })
end)

-- Regression: a leading heading replaced the title even when the div had a
-- title attribute.
t.test("html: a leading heading is the title, unless a title attribute is given; attributes beat the definition", function()
  local r = t.render("callouts.qmd", "html")
  t.in_order(r.text, { "</span>Heading title\n", "Body with a heading title." })
  t.not_contains(r.text, ">Heading title</h2>")
  t.in_order(r.text, { "callout-style-simple callout-todo no-icon", "</span>Attribute title\n", ">Kept heading</h2>" })
end)

-- Regression: the div's id, other classes and attributes were dropped, so the
-- callout couldn't be linked to or placed with a class such as .column-margin.
t.test("html: the div's id, other classes and attributes stay on the callout", function()
  local r = t.render("callouts.qmd", "html")
  t.contains(r.text, '<div id="my-todo" class="extra callout callout-style-simple callout-todo no-icon callout-titled" data-x="1">')
end)

t.test("revealjs: the styles use RevealJS's selectors", function()
  local r = t.render("callouts.qmd", "revealjs")
  r:succeeded()
  t.contains(r.text, ".reveal div.callout-todo.callout {")
  t.contains(r.text, ".reveal div.callout-todo.callout-style-default .callout-title {")
end)

-- Regression: in PDF and Typst a heading used as the title also became a
-- section heading.
t.test("pdf: each callout gets its color and icon in a group, a heading title, and its ID", function()
  local r = t.render("callouts.qmd", "latex")
  r:succeeded()
  t.in_order(r.text, { "\\begingroup", "\\definecolor{quarto-callout-color}{HTML}{FFD700}",
    "\\protected\\def\\faInfo{\\ifcsname faStar\\endcsname\\faStar\\else\\faExclamationTriangle\\fi}", "Star body.", "\\endgroup" })
  t.contains(r.text, "\\definecolor{quarto-callout-color}{HTML}{000080}")
  t.contains(r.text, "\\label{my-todo}")
  t.contains(r.text, "\\hspace{0.5em}{Heading title}")
  t.not_contains(r.text, "section{Heading title}")
end)

t.test("typst: each callout gets its color and icon, a heading title, and its ID", function()
  local r = t.render("callouts.qmd", "typst")
  r:succeeded()
  t.contains(r.text, 'background_color: rgb("#FFD700").lighten(87%), icon_color: rgb("#FFD700")')
  t.contains(r.text, 'if "star" in fa-icon-map { fa-icon("star", solid: true) }')
  t.contains(r.text, 'if "github" in fa-icon-map { fa-icon("github") }')
  t.contains(r.text, "] <my-todo>")
  t.in_order(r.text, { "title: \n[\nHeading title\n]" })
  t.not_contains(r.text, "= Heading title")
end)

t.test("epub: callouts carry their border and title colors as inline styles", function()
  local r = t.render("callouts.qmd", "epub")
  r:succeeded()
  t.in_order(r.text, { '"border-left-color: #FF0000 !important;"', '"background-color: rgba(255, 0, 0, 0.13);"', "Todo" })
  t.not_contains(r.text, "custom-callout-border")
end)

t.test("gfm: custom types become note alerts that keep their title", function()
  local r = t.render("callouts.qmd", "gfm")
  r:succeeded()
  t.in_order(r.text, { "> [!NOTE]\n>\n> ### Todo\n>\n> Todo body.", "> [!NOTE]\n>\n> ### Quiet one" })
end)
