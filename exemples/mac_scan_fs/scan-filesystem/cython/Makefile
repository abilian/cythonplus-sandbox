
ifeq (,)

INCLUDE_DIRS = -I/usr/include/python3.8

else

INCLUDE_PYTHON = -I/srv/slapgrid/slappart6/srv/runner/shared/python3/2e435adf7e2cb7d97668da52532ac7f3/include/python3.7m

OPENSSL_PATH = /srv/slapgrid/slappart6/srv/runner/shared/openssl/24bd61db512fe6e4e0d214ae77943d75
INCLUDE_OPENSSL = -I$(OPENSSL_PATH)/include
LIBRARY_OPENSSL = -L$(OPENSSL_PATH)/lib
RUNPATH_OPENSSL = -Wl,-rpath=$(OPENSSL_PATH)/lib

FMTLIB_PATH = /srv/slapgrid/slappart6/srv/runner/shared/fmtlib/d524cc3d1a798a140778558556ec6d0c
INCLUDE_FMTLIB = -I$(FMTLIB_PATH)/include
LIBRARY_FMTLIB = -L$(FMTLIB_PATH)/lib
RUNPATH_FMTLIB = -Wl,-rpath=$(FMTLIB_PATH)/lib

INCLUDE_DIRS = $(INCLUDE_PYTHON) $(INCLUDE_OPENSSL) $(INCLUDE_FMTLIB)

LIBPATHS = $(LIBRARY_OPENSSL) $(LIBRARY_FMTLIB)
RUNPATHS = $(RUNPATH_OPENSSL) $(RUNPATH_FMTLIB)

LDFLAGS = $(LIBPATHS) $(RUNPATHS)

endif

EXE = main
CXX = g++
CPPFLAGS = -O2 -g -Wno-unused-result -Wsign-compare -pthread $(INCLUDE_DIRS)
LDFLAGS += -Wl,--unresolved-symbols=ignore-all
LDLIBS = -lcrypto -lfmt
EXT_SUFFIX := $(shell python3 -c "import sysconfig; print(sysconfig.get_config_var('EXT_SUFFIX'))")
EXT = $(EXE)$(EXT_SUFFIX)

# Build with Python runtime
all: $(EXT)

$(EXT): setup.py
	@echo "[Cython Compiling $^ -> $@]"
	python3 setup.py build_ext --inplace

# Run with Python runtime
run: $(EXT)
	python3 -c "import $(EXE); $(EXE).python_main()" 2>/dev/null

# Build without Python runtime
nopython: $(EXE)

%.cpp: %.pyx
	@echo "[Cython Compiling $^ -> $@]"
	python3 -c "from Cython.Compiler.Main import main; main(command_line=1)" $^ --cplus -3
	@rm -f $(subst .cpp,.h,$@)

%: %.cpp
	@echo "[C++ Compiling $^ -> $@]"
	$(LINK.cpp) $^ $(LOADLIBES) $(LDLIBS) -o $@

# Run without Python runtime
runnopython: $(EXE)
	./$(EXE) 2>/dev/null

clean:
	-rm -f *.c *.cpp *.html
	-rm -f *.h
	-rm -f *.so
	-rm -f $(EXE)
	-rm -f *.o
	-rm -f -r build
	-rm -f *.json

.PHONY: all run nopython runnopython clean
.PRECIOUS: %.cpp
