#!/usr/bin/env python

import xmlwitch
from time import perf_counter


def test_large():
    xml = xmlwitch.Builder(version="1.0")
    for geo in range(5):
        with xml.Geo(zone=str(geo)):
            for area in range(5):
                with xml.Area(where=str(area)):
                    for city in range(40):
                        with xml.City:
                            xml.Name(f"name of city {city}")
                            xml.Location(f"location of city {city}")
                            for item in range(50):
                                xml.item(ref=str(item), number="10", date="2022-1-1")
    return str(xml)


def main():
    print("-------------------------------------")
    print("Test large - python xmlwitch")
    t0 = perf_counter()
    content = test_large()
    dt = (perf_counter() - t0) * 1000
    print(f"Duration (ms): {dt:.0f}")
    print("-------------------------------------")
    print(f"Size (MB): {len(content)/(2**20):.2f}")
    print("\n".join(content.splitlines()[:8]))
    print("...")
    print("-------------------------------------")
    print()


if __name__ == "__main__":
    main()
