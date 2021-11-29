#!/usr/bin/env python3

# Developed with Python 3.8.5

import sys
import os
import stat
import traceback
import hashlib
import io
import multiprocessing
import json


def compute_hashes(entry_path):
    with open(entry_path, mode="rb") as f:
        md5 = hashlib.md5()
        sha1 = hashlib.sha1()
        sha256 = hashlib.sha256()
        sha512 = hashlib.sha512()

        while True:
            data = f.read(io.DEFAULT_BUFFER_SIZE)

            md5.update(data)
            sha1.update(data)
            sha256.update(data)
            sha512.update(data)

            if len(data) < io.DEFAULT_BUFFER_SIZE:
                break

    return {"md5": md5.hexdigest(),
            "sha1": sha1.hexdigest(),
            "sha256": sha256.hexdigest(),
            "sha512": sha512.hexdigest()}


def stat_result_to_dict(stat_result):
    return {
        "st_mode": getattr(stat_result, "st_mode", None),
        "st_ino": getattr(stat_result, "st_ino", None),
        "st_dev": getattr(stat_result, "st_dev", None),
        "st_nlink": getattr(stat_result, "st_nlink", None),
        "st_uid": getattr(stat_result, "st_uid", None),
        "st_gid": getattr(stat_result, "st_gid", None),
        "st_size": getattr(stat_result, "st_size", None),
        "st_atime": getattr(stat_result, "st_atime", None),
        "st_mtime": getattr(stat_result, "st_mtime", None),
        "st_ctime": getattr(stat_result, "st_ctime", None),
        "st_blocks": getattr(stat_result, "st_blocks", None),
        "st_blksize": getattr(stat_result, "st_blksize", None),
        "st_rdev": getattr(stat_result, "st_rdev", None),
        "st_flags": getattr(stat_result, "st_flags", None),
        "st_gen": getattr(stat_result, "st_gen", None),
        "st_birthtime": getattr(stat_result, "st_birthtime", None),
    }


def construct_fs_tree(mp_pool=None, mp_tasks=[], cur_dict=None, path="/", dev_whitelist=None, ignored_dirs=[]):
    is_first_call = False

    if mp_pool == None:
        is_first_call = True
        mp_pool = multiprocessing.Pool()

    if cur_dict == None:
        cur_dict = {"stat": stat_result_to_dict(os.stat(path, follow_symlinks=False)),
                    "childs": dict()}

    if dev_whitelist != None:
        path_stat = cur_dict["stat"]
        if "st_dev" in path_stat:
            if not path_stat["st_dev"] in dev_whitelist:
                return cur_dict

    for dir in ignored_dirs:
        if path.startswith(dir):
            cur_dict["ignored"] = True
            return cur_dict

    try:
        with os.scandir(path) as it:
            for entry in it:
                try:
                    entry_path = os.fsdecode(entry.path)
                    entry_name = os.fsdecode(entry.name)

                    try:
                        entry_stat = os.stat(entry_path, follow_symlinks=False)
                    except Exception:
                        entry_stat = None

                    cur_dict["childs"][entry_name] = {"stat": stat_result_to_dict(entry_stat),
                                                      "childs": dict()}

                    if stat.S_ISDIR(entry_stat.st_mode):
                        construct_fs_tree(mp_pool=mp_pool, mp_tasks=mp_tasks, cur_dict=cur_dict["childs"][entry_name],
                                          path=entry_path, dev_whitelist=dev_whitelist, ignored_dirs=ignored_dirs)
                    elif stat.S_ISREG(entry_stat.st_mode):
                        mp_tasks.append({"result": mp_pool.apply_async(compute_hashes, [entry_path]),
                                         "merge_into": cur_dict["childs"][entry_name]})
                    elif stat.S_ISLNK(entry_stat.st_mode):
                        cur_dict["childs"][entry_name]["symlink_target"] = os.readlink(
                            entry_path)

                except Exception:
                    pass

    except Exception:
        pass

    if is_first_call == True:
        mp_pool.close()

        for task in mp_tasks:
            try:
                result = task["result"].get()

                for k in iter(result):
                    task["merge_into"][k] = result[k]
            except Exception:
                pass

        mp_pool.join()

    return cur_dict


def main():
    ignored_dirs = ["/opt/slapgrid", "/srv/slapgrid"]

    dev_whitelist = list()
    for path in [".", "/", "/boot"]:
        try:
            dev_whitelist.append(
                os.stat(path, follow_symlinks=False).st_dev)
        except FileNotFoundError:
            pass

    tree = construct_fs_tree(path=".", dev_whitelist=dev_whitelist, ignored_dirs=ignored_dirs)

    with open('result.json', 'w') as fp:
        json.dump(tree, fp, indent=2, separators=(',', ': '))


if __name__ == "__main__":
    main()
