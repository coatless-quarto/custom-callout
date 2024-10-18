-- customcallout.lua

-- Custom callouts
local customCallouts = {}

-- Function to parse YAML and extract custom callout definitions
function parseCustomCallouts(meta)
  if not meta['custom-callout'] then return end
  -- quarto.log.output("Custom callouts meta detected")

  -- Iterate over the custom callouts and store them in a table
  for k, v in pairs(meta['custom-callout']) do
    if type(v) == "table" then
      customCallouts[k] = {
        icon = v.icon or "⚠️",
        color = v.color or "default",
        title = v.title or k:gsub("^%l", string.upper)
      }
    end
  end

end

-- Function to process divs and convert to custom callouts
filter_custom_div = {
  Div = function (div)
    
    -- Identify the div classes
    -- quarto.log.output("Processing div with classes:")
    -- quarto.log.output(div.classes)

    -- Iterate over the classes and check if they match a custom callout
    for _, class in ipairs(div.classes) do
      -- quarto.log.debug("Processing div on class: " .. class)

      -- If the class matches a custom callout, convert it
      if customCallouts[class] then 

        return quarto.Callout({
          type = class,
          content = div.content,
          title = div.title or customCallouts[class].title,
        })

      end

    end

    return div

  end
}

-- Main function to set up the document processing
function Pandoc(doc)
  
  -- quarto.log.output("Custom callouts:")
  parseCustomCallouts(doc.meta)

  -- quarto.log.output("Loaded definitions:")
  -- quarto.log.output(customCallouts)
  
 
  -- Walk the AST and process divs
  doc.blocks = doc.blocks:walk(filter_custom_div)
  
  return doc
end

-- Return the Pandoc filter
return {
  Pandoc = Pandoc
}