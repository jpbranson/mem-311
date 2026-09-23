"""Export Shelby County Census tracts from BigQuery to GeoJSON (and TopoJSON via mapshaper) for Power BI maps.

Usage: uv run python scripts/export_tract_shapes.py
Writes powerbi/shelby_tracts.geojson; if Node is available, also powerbi/shelby_tracts.topo.json
(the format the Power BI Shape Map visual needs). The feature key is GEOID, which matches
fact_service_requests.census_tract_geoid.
"""
import json
import shutil
import subprocess
from pathlib import Path

from google.cloud import bigquery

OUT = Path(__file__).resolve().parent.parent / "powerbi"
SQL = """
select geo_id, lsad_name, st_asgeojson(st_simplify(tract_geom, 15)) as geom
from `bigquery-public-data.geo_census_tracts.census_tracts_tennessee`
where county_fips_code = '157'
order by geo_id
"""


def main() -> None:
    rows = bigquery.Client(project="mem-311", location="US").query(SQL).result()
    features = [
        {"type": "Feature", "properties": {"GEOID": r.geo_id, "name": r.lsad_name}, "geometry": json.loads(r.geom)}
        for r in rows
    ]
    OUT.mkdir(exist_ok=True)
    geojson = OUT / "shelby_tracts.geojson"
    geojson.write_text(json.dumps({"type": "FeatureCollection", "features": features}), encoding="utf-8")
    print(f"wrote {geojson} ({len(features)} tracts)")

    npx = shutil.which("npx")
    if npx:
        topo = OUT / "shelby_tracts.topo.json"
        subprocess.run([npx, "--yes", "mapshaper", str(geojson), "-o", "format=topojson",
                        "quantization=1e5", f"{topo}"], check=True)
        print(f"wrote {topo}")
    else:
        print("npx not found; convert the GeoJSON to TopoJSON at https://mapshaper.org")


if __name__ == "__main__":
    main()
