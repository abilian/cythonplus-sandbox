use anyhow::Result;
use rayon::prelude::*;
use serde::Serialize;
use std::collections::HashMap;
use std::{
    fs::DirEntry,
    fs::File,
    io::{Read, Write},
    path::PathBuf,
    path::Path,
    sync::{Arc, Mutex},
};

#[derive(Debug, Serialize)]
struct FileStat {
    st_dev: u64,
    st_ino: u64,
    st_nlink: u64,
    st_mode: u32,
    st_uid: u32,
    st_gid: u32,
    st_rdev: u64,
    st_size: i64,
    st_blksize: i64,
    st_blocks: i64,
    st_atime: i64,
    st_atime_nsec: i64,
    st_mtime: i64,
    st_mtime_nsec: i64,
    st_ctime: i64,
    st_ctime_nsec: i64,
}

impl From<nix::sys::stat::FileStat> for FileStat {
    fn from(x: nix::sys::stat::FileStat) -> Self {
        Self {
            st_dev: x.st_dev,
            st_ino: x.st_ino,
            st_nlink: x.st_nlink,
            st_mode: x.st_mode,
            st_uid: x.st_uid,
            st_gid: x.st_gid,
            st_rdev: x.st_rdev,
            st_size: x.st_size,
            st_blksize: x.st_blksize,
            st_blocks: x.st_blocks,
            st_atime: x.st_atime,
            st_atime_nsec: x.st_atime_nsec,
            st_mtime: x.st_mtime,
            st_mtime_nsec: x.st_mtime_nsec,
            st_ctime: x.st_ctime,
            st_ctime_nsec: x.st_ctime_nsec,
        }
    }
}

#[derive(Default, Debug, Serialize)]
struct Tree {
    childs: HashMap<String, Tree>,
    stat: Option<FileStat>,
    ignored: bool,
    symlink_target: Option<String>,
    md5: Option<String>,
    sha1: Option<String>,
    sha256: Option<String>,
    sha512: Option<String>,
}


fn construct_fs_tree(
    cur_tree: Option<Tree>,
    path: &PathBuf,
    dev_whitelist: &Vec<u64>,
    ignored_dirs: &Vec<PathBuf>,
) -> Result<Tree> {
    let mut cur_tree = match cur_tree {
        Some(cur_tree) => cur_tree,
        None => Tree {
            stat: Some(nix::sys::stat::lstat(path)?.into()),
            ..Tree::default()
        },
    };

    if !dev_whitelist.iter().any(|x| match &cur_tree.stat {
        Some(stat) if stat.st_dev == *x => true,
        _ => false,
    }) {
        return Ok(cur_tree);
    }

    if ignored_dirs.iter().any(|x| path.starts_with(x)) {
        cur_tree.ignored = true;
        return Ok(cur_tree);
    }

    let entries: Vec<Result<DirEntry, _>> = match std::fs::read_dir(&path) {
        Ok(x) => x,
        _ => return Ok(cur_tree),
    }
    .collect();

    let cur_tree = {
        let cur_tree = Arc::new(Mutex::new(cur_tree));

        entries.par_iter().for_each(|entry| match entry {
            Ok(entry) => {
                let mut tree = Tree {
                    stat: match nix::sys::stat::lstat(&entry.path()) {
                        Ok(s) => Some(s.into()),
                        _ => None,
                    },
                    ..Tree::default()
                };

                match entry.file_type() {
                    Ok(file_type) if file_type.is_dir() => {
                        tree = construct_fs_tree(
                            Some(tree),
                            &entry.path(),
                            dev_whitelist,
                            ignored_dirs,
                        )
                        .unwrap();
                    }
                    Ok(file_type) if file_type.is_file() => {
                        if let Ok(mut file) = std::fs::File::open(&entry.path()) {
                            use md5::{Digest, Md5};
                            use sha1::Sha1;
                            use sha2::{Sha256, Sha512};

                            let mut md5 = Md5::new();
                            let mut sha1 = Sha1::new();
                            let mut sha256 = Sha256::new();
                            let mut sha512 = Sha512::new();

                            let buf: &mut [u8] = &mut [0; 64 * 1024];
                            loop {
                                match file.read(buf) {
                                    Ok(0) => {
                                        tree.md5 = Some(hex::encode(md5.finalize()));
                                        tree.sha1 = Some(hex::encode(sha1.finalize()));
                                        tree.sha256 = Some(hex::encode(sha256.finalize()));
                                        tree.sha512 = Some(hex::encode(sha512.finalize()));
                                        break;
                                    }
                                    Ok(n) => {
                                        md5.update(&buf[0..n - 1]);
                                        sha1.update(&buf[0..n - 1]);
                                        sha256.update(&buf[0..n - 1]);
                                        sha512.update(&buf[0..n - 1]);
                                    }
                                    Err(e) if e.kind() == std::io::ErrorKind::Interrupted => {
                                        continue;
                                    }
                                    Err(e) => {
                                        eprintln!("{:#?}", e);
                                        break;
                                    }
                                };
                            }
                        }
                    }
                    Ok(file_type) if file_type.is_symlink() => {
                        tree.symlink_target = match std::fs::read_link(&entry.path()) {
                            Ok(target) => match target.to_str() {
                                Some(target_str) => Some(String::from(target_str)),
                                None => Some(String::from("<invalid unicode error>")),
                            }
                            Err(_) => None,
                        }
                    }
                    _ => {}
                };

                {
                    let mut locked = cur_tree.lock().unwrap();
                    locked
                        .childs
                        .insert(entry.file_name().to_str().unwrap().to_string(), tree);
                }
            }
            _ => {}
        });

        Arc::try_unwrap(cur_tree).unwrap().into_inner().unwrap()
    };

    Ok(cur_tree)
}

fn main() -> Result<()> {
    let ignored_dirs = ["/opt/slapgrid", "/srv/slapgrid"]
        .iter()
        .map(PathBuf::from)
        .collect();

    let disk_partitions = [".", "/", "/boot"];

    let dev_whitelist = disk_partitions
        .iter()
        .filter_map(|p| match nix::sys::stat::lstat(&PathBuf::from(p)) {
            Ok(stat) => Some(stat.st_dev),
            Err(_) => None,
        })
        .collect();

    let tree = construct_fs_tree(
            None,
            &PathBuf::from("."),
            &dev_whitelist,
            &ignored_dirs,
        )?;

    let result = serde_json::to_string_pretty(&tree)?;

    let path = Path::new("result.json");

    let mut file = File::create(&path).unwrap();

    file.write_all(result.as_bytes()).unwrap();

    Ok(())
}
