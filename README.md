# iPraktikum '21 TUMSM

Our system provides a convenient solution for physicians/doctors to provide telemonitoring services to athletes/patients.

Athletes will use an [iPhone App](/iPhone) to easily send their health data to their physician. Physicians will use an [iPad App](/iPad) to monitor their athletes and provide feedback on their progress. The [Server](/Server) provides the necessary services for data storage, processing and account management.

## Documentation

To build the documentation, you can use one of the following commands

    mkdocs build    # generate static html page in ./site
    make docs-all   # same as `mkdocs build`, but also build iOS reference docs using jazzy

To preview the built documentation in `./site/`, use

    make docs-serve # serves files under ./site generated using `make docs-all`

To get a live view of the documentation while you are editing its Markdown files, use

    mkdocs serve    # serve documentation on localhost:8000

To build a PDF version, set the `ENABLE_PDF_OUTPUT` environment variable

    ENABLE_PDF_OUTPUT=1 mkdocs build

To learn more about the documentation of this project, see the [Documentation Guide](/documentation)
