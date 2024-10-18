# Customcallout Extension For Quarto

> [!IMPORTANT]
>
> This extension is under development and is not yet ready for use.

The `customcallout` extension provides a YAML interface to configure a Quarto Callout Block with custom values.

## Installing

```bash
quarto add coatless-quarto/customcallout
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using

To use the extension, add the following to your document's YAML front matter:

```yaml
custom-callout:
    todo: 
        title: "TODO"
    jjb:
        title: "JJB"
```

This will create two custom callouts: `todo` and `jjb`. The `title` field is required and will be displayed in the callout block.

> [!NOTE]
>
> We're currently working on supporting additional fields for the callout block like color, icon, and more.


## Example

Here is the source code for a minimal example: [example.qmd](example.qmd).

