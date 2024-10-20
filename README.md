# Custom Callout Extension For Quarto <img src="https://github.com/user-attachments/assets/7edadf64-a304-436c-b54f-2f76def14c14" align ="right" alt="" width ="150"/>

> [!IMPORTANT]
>
> This extension is under development and is not yet ready for use.

The `custom-callout` extension provides a YAML interface to configure a Quarto Callout Block with custom values.

## Installing

To install the `custom-callout` extension, follow these steps:

1. Open your terminal.
2. Navigate to your Quarto project directory.
3. Execute the following command:

```bash
quarto add coatless-quarto/customcallout
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

The `custom-callout` extension allows you to define custom callouts in your YAML front matter and then use them in your Quarto documents.
Here's a quick overview of the available YAML options:

| Option | Description | Example |
|--------|-------------|---------|
| `title` | Default title for the callout (optional) | `title: "Important Note"` |
| `icon` | Use a default icon (optional) | `icon: true` |
| `icon-symbol` | Custom symbol or text for the icon | `icon-symbol: "📝"` |
| `color` | Color for the callout's left border and icon | `color: "#FFA500"` |
| `appearance` | Callout appearance (optional) | `appearance: simple` |
| `collapse` | Make the callout collapsible (optional) | `collapse: true` |

You can start using custom callouts in your Quarto project immediately after installation. First, define your custom callouts in the YAML front matter:

```yaml
custom-callout:
  todo:
    icon-symbol: "📝"
    color: "pink"
  test:
    title: "Testing Note"
    icon-symbol: "⚠️"
    color: "#FFA500"
filters:
- custom-callout
```


Then, use the custom callouts in your Markdown content:

```markdown
::: todo
Remember to complete this section.
:::

::: test
This information is crucial for understanding the concept.
:::
```

## Examples

Here are some examples of custom callouts in action:

::: {.todo}
This is a custom 'todo' callout with a pink border and a pencil icon.
:::

::: {.test}
This is a custom 'test' callout with an orange border and a warning icon.
:::


## References

There has been a lot of work done on the `callout` block in Quarto. Here are some references:

- Discussion/Issue Tickets:
   - [Custom filter for processing Github/Obsidian style callouts stopped working - any tips? ](https://github.com/quarto-dev/quarto-cli/discussions/6550)
   - [Creating new callout types (and sharing as an extension)?](https://github.com/quarto-dev/quarto-cli/discussions/7753)
   - [Custom callout boxes](https://github.com/quarto-dev/quarto-cli/issues/844)   
- Official
   - [Quarto: Callout Lua API Reference](https://quarto.org/docs/prerelease/1.3/custom-ast-nodes/callout.html)
   - [Quarto: Callout Blocks](https://quarto.org/docs/authoring/callouts.html)

- Source Code
    - SCSS: <https://github.com/quarto-dev/quarto-cli/blob/71945532e1fc1a5cf113117f6d5ff5bee3991797/src/resources/formats/html/bootstrap/_bootstrap-rules.scss#L1520-L1620>
    - LaTeX: <https://github.com/quarto-dev/quarto-cli/blob/71945532e1fc1a5cf113117f6d5ff5bee3991797/src/resources/filters/quarto-pre/meta.lua#L11>
