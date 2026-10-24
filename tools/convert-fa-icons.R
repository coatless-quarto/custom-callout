# Load required libraries
library(stringr)

# Read the CSS file (non-minified to capture all aliases)
css_content <- readLines("https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@7.2.0/css/all.css")

# Collapse into a single string to match multi-line rules
css_single <- paste(css_content, collapse = "\n")

# Function to convert unicode to Lua safe string format
unicode_to_lua_string <- function(hex) {
  sprintf('"\\\\%s"', hex)
}

# Extract class names and raw --fa values
# FA 7 uses three value styles:
#   --fa: "\f164"    (hex unicode escape)
#   --fa: "A"        (literal character)
#   --fa: "\30 "     (CSS unicode escape with trailing space)
#   --fa: "\*"       (CSS escaped special char)
pattern <- "\\.(fa-[\\w-]+)\\s*\\{\\s*--fa:\\s*\"([^\"]+)\""
matches <- do.call(rbind, str_match_all(css_single, pattern))

fa_data <- data.frame(
  class = matches[, 2],
  raw_value = matches[, 3],
  stringsAsFactors = FALSE
)

# Convert raw CSS values to Lua unicode escape strings
fa_data$lua_unicode <- sapply(fa_data$raw_value, function(val) {
  # Case 1: Standard hex escape like \f164
  if (grepl("^\\\\[0-9a-fA-F]{2,}", val)) {
    hex <- trimws(sub("^\\\\", "", val))
    return(sprintf('"\\\\%s"', hex))
  }
  # Case 2: CSS escaped special char like \* \$ \!
  if (grepl("^\\\\.", val)) {
    ch <- sub("^\\\\", "", val)
    return(sprintf('"\\\\%x"', utf8ToInt(ch)[1]))
  }
  # Case 3: Literal character like A, 0, +
  sprintf('"\\\\%x"', utf8ToInt(val)[1])
})

# Remove duplicates (keep first occurrence)
fa_data <- fa_data[!duplicated(fa_data$class), ]

# Brand icons are in a separate font (fa-brands-400.woff2) and are defined in
# brands.css. A few names there are also in the core set (fontawesome.css),
# which the solid font covers, so those stay with the solid icons.
css_classes <- function(url) {
  css <- paste(readLines(url), collapse = "\n")
  str_match_all(css, "\\.(fa-[\\w-]+)\\s*\\{\\s*--fa:")[[1]][, 2]
}
brand_classes <- setdiff(
  css_classes("https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@7.2.0/css/brands.css"),
  css_classes("https://cdn.jsdelivr.net/npm/@fortawesome/fontawesome-free@7.2.0/css/fontawesome.css")
)
fa_data$brand <- fa_data$class %in% brand_classes

# Generate Lua tables
lua_table <- function(rows) {
  paste0('  ["', rows$class, '"] = ', rows$lua_unicode, ",\n", collapse = "")
}

lua_accessor <- paste0(
  "---Gets the CSS Unicode escape for a FontAwesome icon name\n",
  "---@param icon_name string The icon class, such as \"fa-thumbs-up\"\n",
  "---@return string|nil unicode The escape, or nil if the icon is unknown\n",
  "local function fa_unicode(icon_name)\n",
  "  return fa_icons[icon_name] or fa_brand_icons[icon_name]\n",
  "end\n\n",
  "---Checks whether a FontAwesome icon is in the brands font\n",
  "---@param icon_name string The icon class, such as \"fa-github\"\n",
  "---@return boolean is_brand True if the icon needs the brands font\n",
  "local function fa_is_brand(icon_name)\n",
  "  return fa_brand_icons[icon_name] ~= nil\n",
  "end\n\n",
  "---Lists the names of a FontAwesome icon: the given name first, then the other\n",
  "---names for the same icon in the same font (older or newer names), sorted\n",
  "---@param icon_name string The icon class, such as \"fa-house\"\n",
  "---@return string[] names The icon classes, or an empty list if the icon is unknown\n",
  "local function fa_aliases(icon_name)\n",
  "  local icons = fa_brand_icons[icon_name] and fa_brand_icons or fa_icons\n",
  "  local unicode = icons[icon_name]\n",
  "  if unicode == nil then\n",
  "    return {}\n",
  "  end\n",
  "  local others = {}\n",
  "  for name, code in pairs(icons) do\n",
  "    if code == unicode and name ~= icon_name then\n",
  "      others[#others + 1] = name\n",
  "    end\n",
  "  end\n",
  "  table.sort(others)\n",
  "  table.insert(others, 1, icon_name)\n",
  "  return others\n",
  "end\n\n",
  "return {\n",
  "  fa_unicode = fa_unicode,\n",
  "  fa_is_brand = fa_is_brand,\n",
  "  fa_aliases = fa_aliases\n",
  "}\n"
)

cat(
    "-- Icons in the solid font (fa-solid-900.woff2)\n",
    "local fa_icons = {\n",
    lua_table(fa_data[!fa_data$brand, ]),
    "}\n\n",
    "-- Icons in the brands font (fa-brands-400.woff2)\n",
    "local fa_brand_icons = {\n",
    lua_table(fa_data[fa_data$brand, ]),
    "}\n\n",
    file = "_extensions/custom-callout/fa.lua",
    sep = ""
)

cat(
    lua_accessor,
    file = "_extensions/custom-callout/fa.lua",
    sep = "",
    append = TRUE
)

print(sprintf("Lua tables have been generated with %d icons (%d brands) and saved to 'fa.lua'", nrow(fa_data), sum(fa_data$brand)))
