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

# Generate Lua table
lua_table <- paste0('  ["', fa_data$class, '"] = ', fa_data$lua_unicode, ",\n", collapse = "")

lua_accessor <- paste0(
  "-- Function to get Unicode value for a FontAwesome icon name\n",
  "local function fa_unicode(icon_name)\n",
  "  return fa_icons[icon_name] or nil\n",
  "end\n\n",
  "return {\n",
  "  fa_unicode = fa_unicode\n",
  "}\n"
)

cat(
    "local fa_icons = {\n",
    lua_table,
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

print(sprintf("Lua table has been generated with %d icons and saved to 'fa.lua'", nrow(fa_data)))
