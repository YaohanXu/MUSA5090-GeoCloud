from dotenv import load_dotenv
load_dotenv()

import os
import json
import pathlib
from google.cloud import storage

RAW_DATA_DIR = pathlib.Path(__file__).parent / 'raw_data'
PREPARED_DATA_DIR = pathlib.Path(__file__).parent / 'prepared_data'

raw_filename = RAW_DATA_DIR / 'phl_pwd_parcels.geojson'
prepared_filename = PREPARED_DATA_DIR / 'phl_pwd_parcels.jsonl'

bucket_name = os.getenv('DATA_LAKE_BUCKET')
storage_client = storage.Client()
bucket = storage_client.bucket(bucket_name)

# Download the raw data from the bucket
raw_blobname = 'raw/phl_pwd_parcels/phl_pwd_parcels.geojson'
blob = bucket.blob(raw_blobname)
blob.download_to_filename(raw_filename)
print(f'Downloaded to {raw_filename}')

# Load the data from the GeoJSON file
with open(raw_filename, 'r') as f:
    data = json.load(f)


# Write the data to a JSONL file
with open(prepared_filename, 'w') as f:
    for feature in data['features']:
        row = feature['properties']
        row['geog'] = (
            json.dumps(feature['geometry'])
            if feature['geometry'] and feature['geometry']['coordinates']
            else None
        )
        f.write(json.dumps(row) + '\n')

print(f'Processed data into {prepared_filename}')

# Upload the prepared data to the bucket
prepared_blobname = 'prepared/phl_pwd_parcels/phl_pwd_parcels.jsonl'
blob = bucket.blob(prepared_blobname)
blob.upload_from_filename(prepared_filename)
print(f'Uploaded to {prepared_blobname}')
