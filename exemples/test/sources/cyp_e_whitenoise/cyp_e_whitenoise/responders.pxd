from collections import namedtuple
from email.utils import formatdate, parsedate
import errno

from http import HTTPStatus
import os
import re
import stat
from time import mktime
from urllib.parse import quote

from wsgiref.headers import Headers

from libcythonplus.dict cimport cypdict
from stdlib._string cimport string
from stdlib.string cimport Str
from .scan cimport Finfo, Fdict, from_str, to_str


cdef make_static_file(str, dict, Fdict)


cdef file_stats(Str, Fdict)
