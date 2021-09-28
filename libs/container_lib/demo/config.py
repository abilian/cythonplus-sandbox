#!/usr/bin/env python
"""Config class using toml
"""

import os
from os.path import exists

import toml


class Config:
    default_conf = {
        "title": "config",
        "content": {"data": [0, 1, 1, 2, 3, 5, 8], "flag": True, "name": "sample"},
        "ratio": 1.5,
    }
    default_path = "config.toml"

    def __init__(self, path=None):
        self.path = path or Config.default_path
        self.timestamp = 0
        self.conf = {}
        if not exists(self.path):
            self.conf = Config.default_conf
            self.dump()
        self.load()

    def load(self):
        # no try/except, better crash
        self.conf = toml.load(self.path)
        self.timestamp = os.stat(self.path).st_mtime

    def dump(self):
        with open(self.path, "w", encoding="utf8") as f:
            toml.dump(self.conf, f)
        self.timestamp = os.stat(self.path).st_mtime

    @property
    def content(self):
        if os.stat(self.path).st_mtime > self.timestamp:
            self.load()
        return self.conf


if __name__ == "__main__":
    c = Config()
    print(c.content)
