#!/usr/bin/env python

from setuptools import setup, find_packages

setup(
    name="demo-flask-vuejs-rest",
    version="1.0",
    # Modules to import from other scripts:
    packages=find_packages(),
    # Executables
    entry_points={
        "console_scripts": [
            "web_interface=testing.web_interface:main",
        ],
    },
)
