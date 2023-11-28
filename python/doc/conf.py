# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# See also: https://github.com/networkx/networkx/blob/main/doc/conf.py

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information
from datetime import date
import moocore

project = "moocore"
_full_version = moocore.__version__
release = _full_version.split("+", 1)[0]
version = ".".join(release.split(".")[:2])
year = date.today().year
author = "Manuel López-Ibáñez and Fergus Rooney"
copyright = f"2023-{year}, {author}"

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

html_js_files = [
    "https://cdnjs.cloudflare.com/ajax/libs/require.js/2.3.4/require.min.js"
]

extensions = [
    "sphinx.ext.autodoc",  # Core Sphinx library for auto html doc generation from docstrings
    "sphinx.ext.autosummary",  # Create neat summary tables for modules/classes/methods etc
    "sphinx.ext.napoleon",
    "sphinx.ext.intersphinx",  # Link to other project's documentation (see mapping below)
    "sphinx.ext.viewcode",  # Add a link to the Python source code for classes, functions etc.
    "sphinx_autodoc_typehints",  # Automatically document param types (less noise in class signature)
    "sphinx_copybutton",  # A small sphinx extension to add a "copy" button to code blocks.
    "sphinx.ext.doctest",
    "sphinx.ext.extlinks",
    "sphinx.ext.mathjax",
    "myst_nb",
    "sphinx.ext.autosectionlabel",
    "sphinxcontrib.bibtex",
]
# enable autosummary plugin (table of contents for modules/classes/class
# methods)
autosummary_generate = True
autosummary_generate_overwrite = False
autosummary_ignore_module_all = False
add_module_names = False
autosummary_imported_members = True  # Also documents imports in __init__.py
napoleon_include_init_with_doc = True

bibtex_bibfiles = ["REFERENCES.bib"]
bibtex_reference_style = "author_year"
html_theme = "pydata_sphinx_theme"
html_theme_options = {
    "collapse_navigation": False,
    #    "navigation_depth": 2,
    "show_prev_next": True,
    "use_edit_page_button": True,
    #    "style_external_links": True,
    "primary_sidebar_end": ["indices.html", "sidebar-ethical-ads.html"],
    "icon_links": [
        {
            # Label for this link
            "name": "GitHub",
            # URL where the link will redirect
            "url": "https://github.com/auto-optimization/moocore",  # required
            # Icon class (if "type": "fontawesome"), or path to local image (if "type": "local")
            "icon": "fa-brands fa-square-github",
            # The type of image to be used (see below for details)
            "type": "fontawesome",
        }
    ],
}
# Removes, from all docs, the copyright footer.
html_show_copyright = False

html_context = {
    "display_github": True,
    "github_user": "auto-optimization",
    "github_repo": "moocoore",
    "github_version": "main",
    "doc_path": "doc",
}
# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ["_static"]
html_css_files = [
    "css/custom.css",
]
templates_path = ["_templates"]
# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path .
exclude_patterns = [
    "_build",
    "Thumbs.db",
    ".DS_Store",
    "**.ipynb_checkpoints",
    "_templates",
    "modules.rst",
    "source",
]
suppress_warnings = ["mystnb.unknown_mime_type"]

# If true, '()' will be appended to :func: etc. cross-reference text.
add_function_parentheses = True

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

# html_permalinks_icon = "<span>#</span>"

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = "sphinx"

# Napoleon settings
napoleon_google_docstring = False
napoleon_numpy_docstring = True
napoleon_preprocess_types = True

# Intersphinx mapping
intersphinx_mapping = {
    "python": ("https://docs.python.org/3/", None),
    "numpy": ("https://numpy.org/doc/stable/", None),
    "neps": ("https://numpy.org/neps/", None),
    "matplotlib": ("https://matplotlib.org/stable/", None),
    "scipy": ("https://docs.scipy.org/doc/scipy/", None),
    "pandas": ("https://pandas.pydata.org/pandas-docs/stable/", None),
    "geopandas": ("https://geopandas.org/en/stable/", None),
    "pygraphviz": ("https://pygraphviz.github.io/documentation/stable/", None),
    "sphinx-gallery": ("https://sphinx-gallery.github.io/stable/", None),
    "nx-guides": ("https://networkx.org/nx-guides/", None),
    "sympy": ("https://docs.sympy.org/latest/", None),
}
