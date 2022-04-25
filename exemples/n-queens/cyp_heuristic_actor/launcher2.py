#!/usr/bin/env python

import importlib
import atexit
from os import unlink, getpid
from os.path import exists, join, getmtime
from time import perf_counter, sleep
import multiprocessing as mp
import psutil
import json
import toml

PARAMS_FILE = "params2.toml"
RESULT_FILE = "result.json"
PID_FILE = "/tmp/launcher2.pid"


def load_params():
    path = PARAMS_FILE
    if not exists(path):
        return {}
    # no try/except, better crash
    return toml.load(path)


def remove_pid_file():
    if exists(PID_FILE):
        try:
            unlink(PID_FILE)
        except OSError:
            pass


def start_sentinel():
    pid = getpid()
    with open(PID_FILE, "w", encoding="utf8") as f:
        f.write(f"{pid}\n")
        f.flush()
    d = mp.Process(target=sentinel_daemon, args=(pid,))
    d.daemon = True
    d.start()


def sentinel_daemon(pid):
    last_changed = 0.0
    while True:
        # check status_file, quit all if not ok
        if not exists(PID_FILE):
            break
        mtime = getmtime(PID_FILE)
        if mtime == last_changed:
            # file not modified
            sleep(0.5)
            continue
        # file changed (or first cycle)
        last_changed = mtime
        try:
            with open(PID_FILE, "r", encoding="utf8") as f:
                read_pid = int(f.read())
        except OSError:
            break
        if read_pid != pid:
            # not same pid ? another calculation started ?
            break
    # kill main process
    my_pid = getpid()
    parent = psutil.Process(pid)
    procs = parent.children(recursive=True)
    procs.append(parent)
    procs = [p for p in procs if p.pid != my_pid]
    for p in procs:
        try:
            p.terminate()
        except:
            pass
    _gone, still_alive = psutil.wait_procs(procs, timeout=2)
    for p in still_alive:
        p.kill()
    # end of myself by returning


def save_result(cpt, args, duration):
    if exists(RESULT_FILE):
        with open(RESULT_FILE, encoding="utf8") as f:
            result = json.load(f)
    else:
        result = []
    result.append({"nb": cpt, "args": args, "duration": duration})
    with open(RESULT_FILE, "w", encoding="utf8") as f:
        json.dump(result, f)


def worker(module, function_name, args, cpt):
    function = getattr(importlib.import_module(".", module), function_name)
    t0 = perf_counter()
    function(*args)
    duration = t0 = perf_counter() - t0
    print(f"duration: {duration:3.3f}s\n")
    save_result(cpt, args, duration)


def launch():
    mp.set_start_method("spawn")
    atexit.register(remove_pid_file)
    start_sentinel()
    if exists(RESULT_FILE):
        unlink(RESULT_FILE)
    params = load_params()
    module = params["module"]
    function_name = params.get("function", "main")
    default_title = params.get("default_title", "")
    tests = params.get("test", [])
    nb_tests = len(tests)
    cpt = 0
    for test in tests:
        cpt += 1
        title = test.get("title", default_title)
        args = test.get("args", [])
        print(f"{cpt}/{nb_tests} - {title}")
        print(f"params: {args}")
        worker_args = [module, function_name, args, cpt]
        p = mp.Process(target=worker, args=worker_args, daemon=True)
        p.start()
        p.join()


if __name__ == "__main__":
    launch()
