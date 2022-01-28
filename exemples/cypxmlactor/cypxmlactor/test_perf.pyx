from stdlib.string cimport Str
from stdlib.format cimport format
from libcythonplus.dict cimport cypdict
from libcythonplus.list cimport cyplist

from .cypxml cimport cypXML

from time import perf_counter


cdef bytes test_large():
    cdef cypXML xml
    cdef int geo, area, city, item
    cdef bytes result

    ### code to test
    xml = cypXML()
    xml.init_version(Str("1.0"))
    for geo in range(5):
        g = xml.tag(Str("Geo")).attr(Str("zone"), format("{}", geo))
        for area in range(5):
            a = g.tag(Str("Area")).attr(Str("where"), format("{}", area))
            for city in range(40):
                c = a.tag(Str("City"))
                c.tag(Str("Name")).text(format("name of city {}", city))
                c.tag(Str("Location")).text(format("location of city {}", city))
                for item in range(50):
                    c.tag(format("item")).attr(Str("ref"), format("{}", item)).attr(Str("number"), Str("10")).attr(Str("date"), Str("2022-1-1"))
    result = xml.dump().bytes()
    return result

##############################################################################


def main():
    print("-------------------------------------")
    print("Test large - cythonplus cypXML")
    t0 = perf_counter()
    content = test_large().decode("utf8")
    dt = (perf_counter() - t0) * 1000
    print(f"Duration (ms): {dt:.0f}")
    print("-------------------------------------")
    print(f"Size (MB): {len(content)/(2**20):.2f}")
    print("\n".join(content.splitlines()[:8]))
    print("...")
    print("-------------------------------------")
    print()
