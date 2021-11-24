The file "scheduler.pxd" is adapted from the "runtime.pxd" of the "runtime" repositoryof Cython+ project:
https://lab.nexedi.com/cython-plus/runtime.git

The pthread-barrier lib (licence MIT) comes from:
https://github.com:isotes/pthread-barrier-macos.git

Adaptation for Mac:
- threads.pxd: remove barrier things not avilbale on Apple
- use of custom barrier library.

scheduler.pxd:
- name changed to "scheduler.pxd"
- indentation
- path of thread libraries changed to "scheduler_darwin/"
- add some printf at barrier level in scheduler.pxd code.
  See: diff -u scheduler/scheduler.pxd scheduler_darwin/scheduler.pxd
