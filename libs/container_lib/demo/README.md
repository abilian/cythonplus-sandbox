# demo

A demo of a basic application using containerlib for cython+.
The demo show how to mix .py and .pyx files and how to exchange complex data between
python perimeter and cython+/cypclass perimeter.


- to build and run:

    `./make.sh`

    `python app.py`


- quick description:

    - `app.py` do read a config file, send it to a backend engine, get back
      a dict containing both config and computation result, print it.

    - `app.py` main parts:

      - read a .toml config file (see `config.py`)

      - launch the main engine (see `engine.pyx`)

      - the engine is called by its frontend `py_engine()`

      - py_engine do:

          - conversion PyObject => CyObject

          - run the cypclass Engine

          - conversion of results to PyObject

          - result is a dictionary containing both config and actual result

    - `engine.pyx` uses the `containerlib` files

    - `app.py` uses cython `local.pyx` and `local.pxd` files

    - actual calculation of the engine is to send back a small dictionary
