#!/usr/bin/env python3
import os
import pathlib
import tempfile

import pytest

from macros import include_partial

content = """# Header

This file explains something very interesting.

## Getting Started

This is how you would get started:

```py
print("Hello, World!")
```

!!! example "Example"
    Indented Example Content

## References

* [Python](python.org)

Second last line
Last line
"""


def print_debug(expected, returned):
    print(f"\nEXPECTED: {expected!r}")
    print(f"RETURNED: {returned!r}")


@pytest.fixture(autouse=True)
def add_filepath_to_doctest(doctest_namespace, testfile):
    print("preparing doctests...")
    doctest_namespace["filepath"] = testfile


@pytest.fixture()
def testfile():
    fp = tempfile.NamedTemporaryFile("w", delete=False)
    fp.write(content)
    fp.close()
    yield fp.name
    os.unlink(fp.name)


def test_include_full_file(testfile):
    """Include all content from file."""
    expected = content
    returned = include_partial(testfile)
    print_debug(expected, returned)
    assert returned == returned


def test_include_first_lines(testfile):
    """Include first lines from file."""
    expected = "\n".join(content.split("\n")[:5])
    returned = include_partial(testfile, lines=5)
    print_debug(expected, returned)
    assert returned == returned


@pytest.mark.parametrize(("start", "end"), [(2, 5)])
def test_include_block_by_line_number(testfile, start, end):
    """Include block from file by line number."""
    expected = "".join(pathlib.Path(testfile).open().readlines()[start:end]).rstrip()
    returned = include_partial(testfile, start=start, end=end)
    print_debug(expected, returned)
    assert returned == expected


def test_include_block_by_matching_start_and_end(testfile):
    """Include block from file by matching start and end lines."""
    expected = "\n".join(content.split("\n")[8:11]).rstrip()
    returned = include_partial(
        testfile, start_match="```py", end_match="```", include_last=True
    )
    print_debug(expected, returned)
    assert returned == expected


def test_include_block_by_number_of_lines(testfile):
    """Include block from file by matching start line and fixed number of lines."""
    expected = "\n".join(content.split("\n")[8:11]).rstrip()
    returned = include_partial(testfile, start_match="```py", lines=3)
    print_debug(expected, returned)
    assert returned == expected


def test_wrap_in_raw_tags(testfile):
    """Include content wrapped in jinja raw blocks."""
    expected = "{% raw %}\n" + include_partial(testfile) + "\n{% endraw %}"
    returned = include_partial(testfile, raw=True)
    print_debug(expected, returned)
    assert returned == expected

    args = {"keep_trailing_whitespace": True}
    expected = "{% raw %}\n" + include_partial(testfile, **args) + "{% endraw %}\n"
    returned = include_partial(testfile, raw=True, **args)
    print_debug(expected, returned)
    assert returned == expected


def test_escape(testfile):
    args = {"escape": ["`"], "keep_trailing_whitespace": True}
    expected = content.replace("`", "\\`")
    returned = include_partial(testfile, **args)
    print_debug(expected, returned)
    assert returned == expected


def test_first_character_missing_issue(testfile):
    args = {"start_match": "# ", "start_offset": 1, "keep_trailing_whitespace": True}
    expected = "\n".join(content.split("\n")[1:])
    returned = include_partial(testfile, **args)
    print_debug(expected, returned)
    assert returned == expected


@pytest.mark.parametrize("dedent", [True, False, 6])
def test_dedent(testfile, dedent):
    args = dict(start_match="    ", lines=1, dedent=dedent)
    if dedent == True:
        expected = "".join(
            [line.lstrip() for line in content.split("\n") if line.startswith("    ")]
        )
    elif dedent == False:
        expected = "".join(
            [line for line in content.split("\n") if line.startswith("    ")]
        )
    elif isinstance(dedent, int):
        expected = "".join(
            [line[dedent:] for line in content.split("\n") if line.startswith("    ")]
        )
    returned = include_partial(testfile, **args)
    print_debug(expected, returned)
    assert returned == expected


if __name__ == "__main__":
    import sys

    pytest.main(["-vv", "--capture=tee-sys", *sys.argv[1:]])
