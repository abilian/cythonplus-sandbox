import pyximport

pyximport.install(setup_args={"script_args": ["--force"]}, language_level=3)

from test_any_scalar import *
from test_any_scalar_list import *
from test_any_scalar_dict_multi_level import *
