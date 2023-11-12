from setuptools import setup

setup(
    cffi_modules=["src/moocore/_ffi_build.py:ffibuilder"],
    package_data={"": ["*.h", "*.c"]},
)
