# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information
from datetime import date
import eafpy as eaf

project = "eafpy"
_full_version = eaf.__version__
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
    "sphinx.ext.autodoc",
    "sphinx.ext.napoleon",
    "sphinx.ext.extlinks",
    "sphinx.ext.viewcode",
    "myst_nb",
    "sphinx.ext.autosectionlabel",
]
html_theme = "pydata_sphinx_theme"
html_theme_options = {
    "use_edit_page_button": True,
    "primary_sidebar_end": ["indices.html", "sidebar-ethical-ads.html"],
    "icon_links": [
        {
            # Label for this link
            "name": "GitHub",
            # URL where the link will redirect
            "url": "https://github.com/auto-optimization/eafpy",  # required
            # Icon class (if "type": "fontawesome"), or path to local image (if "type": "local")
            "icon": "fa-brands fa-square-github",
            # The type of image to be used (see below for details)
            "type": "fontawesome",
        }
    ],
}
html_context = {
    "github_user": "auto-optimization",
    "github_repo": "eafpy",
    "github_version": "main",
    "doc_path": "doc",
}
html_static_path = ["_static"]
html_css_files = [
    "css/custom.css",
]

suppress_warnings = ["mystnb.unknown_mime_type"]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

# html_permalinks_icon = "<span>#</span>"


# Napoleon settings
napoleon_google_docstring = False
napoleon_numpy_docstring = True
napoleon_preprocess_types = True
