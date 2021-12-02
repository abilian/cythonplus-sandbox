#!/bin/bash

# export to file:
# python -c "from scan import python_scan_fs as scan; scan('.')"

# export to list, and print string:
python -c "from scan import python_scan_fs_str as scan; scan('.')"
