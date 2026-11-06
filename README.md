# Custom Callout Extension For Quarto <img src="https://github.com/user-attachments/assets/7edadf64-a304-436c-b54f-2f76def14c14" align ="right" alt="" width ="150"/>

The `{quarto-custom-callout}` extension provides a YAML interface to configure a 
Quarto Callout with custom values such as its title, icon, icon symbol, color,
appearance, and collapsibility.

> [!IMPORTANT]
>
> This extension supports Quarto HTML documents and RevealJS presentations,
> and PDF, Typst and EPUB output. See [Other formats](#other-formats) for
> what each format shows.

## Installing

To install the `{quarto-custom-callout}` extension, follow these steps:

1. Open your terminal.
2. Navigate to your Quarto project directory.
3. Execute the following command:

```bash
quarto add coatless-quarto/custom-callout
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

The `custom-callout` extension allows you to define custom callouts in your 
YAML front matter and then use them in your Quarto documents.
Here's a quick overview of the available YAML options:

| Option | Description | Default | Possible Values | Example |
|--------|-------------|---------|-----------------|---------|
| `title` | Default title for the callout | Callout name | Any string | `title: "Important Note"` |
| `icon` | Display an icon | `true` | `true`, `false` | `icon: false` |
| `icon-symbol` | Custom symbol or text for the icon | None | Any string, unicode, or [FontAwesome](https://fontawesome.com/search?o=r&m=free) class | `icon-symbol: "📝"` |
| `color` | Color for the callout's left border and background | None | Any valid CSS color name or hex | `color: "#FFA500"` |
| `appearance` | Callout appearance | `"default"` | `"default"`, `"simple"`, `"minimal"` | `appearance: "simple"` |
| `collapse` | Make the callout collapsible | `false` | `true`, `false` | `collapse: true` |

You can start using custom callouts in your Quarto project immediately
after installation. First, define your custom callouts in the YAML front matter:

```yaml
custom-callout:
  todo:
    icon-symbol: "📝"
    color: "pink"
  test:
    title: "Testing Note"
    icon-symbol: "⚠️"
    color: "#FFA500"
  thumbs-up:
    title: "Great job!"
    icon-symbol: "fa-thumbs-up"
    color: "#008000"
filters:
- custom-callout
```


Then, use the custom callouts in your Quarto document like this:

```markdown
::: todo
Remember to complete this section.
:::

::: test
This information is crucial for understanding the concept.
:::

::: {.thumbs-up title="That was a hard task!"}
You did a great job completing this task.
:::
```

The above example will render three custom callouts in your document: 
one with a pink border and a "📝" icon, an orange
border and a "⚠️" icon, and a green border with a thumbs-up icon from 
[FontAwesome](https://fontawesome.com/search?o=r&m=free).


## Other formats

Custom callouts keep their color and icon in PDF, Typst and EPUB output:

| Format | `color` | FontAwesome icons | Emoji and other symbols |
|--------|---------|-------------------|-------------------------|
| HTML and RevealJS | Yes | Yes | Yes |
| PDF | Yes | Yes, from Font Awesome 5 | Plain ASCII text only |
| Typst | Yes | Yes, from Font Awesome 6 | Yes, when a font has them |
| EPUB | Yes | No | Yes |

- Hex colors, CSS color names and `rgb()` colors work in every format. Other CSS colors, such as `hsl()`, keep Quarto's default color outside HTML.
- When a format can't show an icon, a colored callout shows a warning triangle instead, and the render log has a warning. In PDF, an icon added after Font Awesome 5 shows the triangle.
- In GitHub Markdown, a custom callout becomes a `> [!NOTE]` alert with its title. Word output uses Quarto's default callout styling.

To use a different icon in one format, set it under that format:

```yaml
custom-callout:
  thumbs-up:
    icon-symbol: "fa-thumbs-up"
    color: "#008000"
format:
  html: default
  epub:
    custom-callout:
      thumbs-up:
        icon-symbol: "👍"
filters:
- custom-callout
```

## Notes

The `{quarto-custom-callout}` extension uses Quarto's [`quarto.Callout` custom AST Node](https://quarto.org/docs/prerelease/1.3/custom-ast-nodes/callout.html) to create custom [Quarto Callouts](https://quarto.org/docs/authoring/callouts.html).

Previously, there were two approaches to creating custom callouts. Both approaches rely on using a `Div` node. Specifically, we have:

1. Create custom CSS classes with the necessary styling and apply it to a `Div` node.
2. Use [`{quarto-custom-numbered-blocks}`](https://github.com/ute/custom-numbered-blocks) extension by [Ute Hahn](https://github.com/ute). 

The latter approach is more user-friendly and allows for the creation of 
custom number blocks with a YAML interface. Further, it offers immense flexibility 
in terms of styling and customization compared to the `quarto.Callout()` 
custom AST Node used by `{quarto-custom-callout}`. For example, if you need
grouped callouts, you can use the `groups` option in the 
`{quarto-custom-numbered-blocks}` extension to formulate joint counters and styles.
It's a great extension to use if you need more than just custom callouts.

## License

custom-callout is licensed under AGPL-3.0-or-later with an exception: what you write and render with custom-callout stays yours, along with the output, under any terms you like. See [LICENSE](LICENSE) and [LICENSE-EXCEPTION.md](LICENSE-EXCEPTION.md).
