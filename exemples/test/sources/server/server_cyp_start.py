#!/usr/bin/env python
import os

from server.daemon import Daemon


def main():
    d = Daemon("/tmp/server_cyp.pid", "127.0.0.1", "5016")
    d.start()


if __name__ == "__main__":
    main()
