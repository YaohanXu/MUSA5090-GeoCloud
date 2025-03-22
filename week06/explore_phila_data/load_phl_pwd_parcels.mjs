import dotenv from 'dotenv';
dotenv.config();

import { BigQuery } from '@google-cloud/bigquery';

const bucketName = process.env.DATA_LAKE_BUCKET;
const datasetName = process.env.DATA_LAKE_DATASET;

// Load the data into BigQuery as an external table
const preparedBlobname = 'prepared/phl_pwd_parcels/phl_pwd_parcels.jsonl';
const tableName = 'phl_pwd_parcels';
const tableUri = `gs://${bucketName}/${preparedBlobname}`;

const createTableQuery = `
CREATE OR REPLACE EXTERNAL TABLE \`${datasetName}.${tableName}\`
OPTIONS (
  format = 'JSON',
  uris = ['${tableUri}']
)
`;

const bigqueryClient = new BigQuery();
await bigqueryClient.query(createTableQuery);
console.log(`Loaded ${tableUri} into ${datasetName}.${tableName}`);
