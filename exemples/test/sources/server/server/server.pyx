import os
from os.path import abspath, expanduser, join, relpath
from time import perf_counter

from .httpserver import StaticServer
from .daemon import Daemon
from .common cimport xlog


class Server(Daemon):
    def run(self):
        t0 = perf_counter()
        site = abspath(expanduser("~/tmp/wntest/site1"))
        static_folder = join(site, "static")
        backlog = 1000
        ss = StaticServer(
            self.addr, self.port, static_folder, "static", backlog)
        ss.scan()
        xlog(f"scan duration: {perf_counter() - t0}")
        ss.serve()


def start_server():
    d = Server("/tmp/server_cyp.pid", "127.0.0.1", "5016")
    d.start()
