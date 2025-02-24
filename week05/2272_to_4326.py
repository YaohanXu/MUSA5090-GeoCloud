import csv
import shapely.wkt
import shapely.geometry
from pyproj import Transformer
import itertools
import pathlib

CURDIR = pathlib.Path(__file__).parent
DATADIR = CURDIR / 'data'

def process_properties():
    with open(DATADIR / 'properties.csv') as infile, open(DATADIR / 'properties_processed.csv', 'w') as outfile:
        reader = csv.DictReader(infile)
        writer = csv.DictWriter(outfile, fieldnames=reader.fieldnames + ['geog'])
        writer.writeheader()

        # Loop through the rows in 1000 row chunks
        for chunk in itertools.batched(reader, 50000):
            # Parse the EWKT geometries from the 'shape' column, ignoring the SRID
            # as it is always 2272.
            ingeoms = [shapely.wkt.loads(inrow['shape'].split(';')[1]) for inrow in chunk]
            nonnullrows = [inrow for inrow, ingeom in zip(chunk, ingeoms) if not ingeom.is_empty]
            nonnullgeoms = [geom for geom in ingeoms if not geom.is_empty]
            inX = [geom.x if not geom.is_empty else None for geom in nonnullgeoms]
            inY = [geom.y if not geom.is_empty else None for geom in nonnullgeoms]

            # Project the geometries from EPSG 2272 to EPSG 4326
            transformer = Transformer.from_crs(2272, 4326)
            outX, outY = transformer.transform(inX, inY)
            outgeoms = [shapely.geometry.Point(y, x) if x is not None and y is not None else None for x, y in zip(outX, outY)]

            outrows = [{**inrow, 'geog': outgeom.wkt} for inrow, outgeom in zip(nonnullrows, outgeoms)]
            writer.writerows(outrows)


if __name__ == '__main__':
    process_properties()