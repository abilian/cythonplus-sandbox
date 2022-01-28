# cypxmlactor, XML generator written in Cython+

## About

`cypxmlactor` provides quite the same functionalities as `xmlwitch`. Both libraries have
quite the same performances for now:
  - see: `test_perf.sh`
  - `xmlwitch` writes sequentially the generated XML into a BytesIO(), which
      is quite fast.
  - `cypxmlactor` generate a Str() for each XML Tag, from the Str() of each XML child,
    recursively. This is a slower algo than `xmlwitch`, but will permit some multicore
    implementation.

## Building the library

Requires:  Cython+ environment


Run: `make.sh`


## Usage

Cython+ code:


Result:

    <?xml version="1.0" encoding="utf-8"?>
    <Geo zone="0">
      <Area where="0">
        <City>
          <Name>name of city 0</Name>
          <Location>location of city 0</Location>
          <item ref="0" number="10" date="2022-1-1" />
          <item ref="1" number="10" date="2022-1-1" />

Code with the python library xmlwitch for the same result:

    import xmlwitch

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


## Bench

Quick test:

```

```
