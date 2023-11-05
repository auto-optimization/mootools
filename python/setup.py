from setuptools import setup

setup(
    cffi_modules=["src/moocore/build_c_moocore.py:ffibuilder"],
    package_data={"": ["*.h", "*.c"]},
)
