# Asset Management

## Use relative image paths

As discussed in [mkdocs#1757](https://github.com/mkdocs/mkdocs/issues/1757), relative paths should be used for images. Specifically, while relative paths will be rewritten to be relative to `site_url`, absolute paths will **not** be rewritten which causes them to break if the pages are hosted in a subdirectory of the server.
