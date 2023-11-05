import pytest
import moocore

@pytest.fixture(autouse=True)
def add_np(doctest_namespace):
    doctest_namespace["moocore"] = moocore
