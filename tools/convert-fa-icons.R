# Load required libraries
library(stringr)

# Read the CSS file
css_content <- readLines("https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css")

# Function to convert unicode to Lua safe string format
unicode_to_lua_string <- function(hex) {
  sprintf('"\\\\%s"', hex)
}

# Extract class names and unicode values
pattern <- "\\.(fa-[\\w-]+):before\\{content:\"\\\\([\\w]+)\"\\}"
matches <- str_match_all(css_content, pattern)

# Combine all matches
all_matches <- do.call(rbind, matches)

# Create a data frame
fa_data <- data.frame(
  class = all_matches[, 2],
  unicode = all_matches[, 3],
  stringsAsFactors = FALSE
)

# Convert unicode values to Lua string format
fa_data$lua_unicode <- sapply(fa_data$unicode, unicode_to_lua_string)

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

print("Lua table has been generated and saved to 'fa.lua'")