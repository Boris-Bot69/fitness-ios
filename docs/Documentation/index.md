# About this Documentation

This documentation is built using MkDocs.

[:octicons-mark-github-16: Repository](https://github.com/mkdocs/mkdocs) ︱ [:octicons-book-24: Documentation](https://mkdocs.org/)

## Theme

This documentation uses the [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme.

[:octicons-mark-github-16: Repository](https://github.com/squidfunk/mkdocs-material) ︱ [:octicons-book-24: Documentation](https://squidfunk.github.io/mkdocs-material/)


## Used Plugins

```yaml
{{include_partial('mkdocs.yml', start_match='plugins:', end_match='extra:', end_offset=0)}}
```

### macros

[:octicons-book-24: Documentation](https://mkdocs-macros-plugin.readthedocs.io/)

!!! info "See Also"
    For more information about custom macros, see [`macros.py` Documentation](../macros)!

### mkdocstrings

[:octicons-book-24: Documentation](https://mkdocstrings.github.io/)

### pdf-export

[:octicons-mark-github-16: Repository](https://github.com/zhaoterryy/mkdocs-pdf-export-plugin)

## Documentation File Layout

    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        ...       # Other markdown pages, images and other files.
