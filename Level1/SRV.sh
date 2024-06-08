#!/bin/bash


gcloud services disable dataflow.googleapis.com
gcloud services enable dataflow.googleapis.com

export PROJECT_ID=$(gcloud config get-value project)

PROJECT_NUMBER=$(gcloud projects describe $(gcloud config get-value project) --format='get(projectNumber)')

gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${PROJECT_NUMBER}-compute@developer.gserviceaccount.com" \
  --role="roles/editor"



 sudo apt-get install -y python3-venv
 python3 -m venv df-env
 source df-env/bin/activate


python3 -m pip install -q --upgrade pip setuptools wheel
python3 -m pip install apache-beam[gcp]


EMAIL_ID=$(gcloud config get-value account)

cat > cp-channel.json <<EOF_CP
{
  "type": "email",
  "displayName": "Qwiklabs Student",
  "description": "Subscribe to Techcps",
  "labels": {
    "email_address": "$EMAIL_ID"
  }
}
EOF_CP


gcloud beta monitoring channels create --channel-content-from-file="cp-channel.json"



channel_info=$(gcloud beta monitoring channels list)

channel_id=$(echo "$channel_info" | grep -oP 'name: \K[^ ]+' | head -n 1)

# app-engine-error-percent-policy.json

cat > app-engine-error-percent-policy.json <<EOF_END
{
  "displayName": "Failed Dataflow Job",
  "userLabels": {},
  "conditions": [
    {
      "displayName": "Dataflow Job - Failed",
      "conditionThreshold": {
        "filter": "resource.type = \"dataflow_job\" AND metric.type = \"dataflow.googleapis.com/job/is_failed\"",
        "aggregations": [
          {
            "alignmentPeriod": "300s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_SUM"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "0s",
        "trigger": {
          "count": 1
        },
        "thresholdValue": 0
      }
    }
  ],
  "alertStrategy": {},
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [
    "$channel_id"
  ],
  "severity": "SEVERITY_UNSPECIFIED"
}
EOF_END


gcloud alpha monitoring policies create --policy-from-file="app-engine-error-percent-policy.json"



cat > my_pipeline.py <<'EOF_CP'
import argparse
import logging
import argparse, logging, os
import apache_beam as beam
from apache_beam.io import WriteToText
from apache_beam.options.pipeline_options import PipelineOptions

class ReadGBK(beam.DoFn):

 def process(self, e):
   k, elems = e
   for v in elems:
     logging.info(f"the element is {v}")
     yield v


def run(argv=None):
   parser = argparse.ArgumentParser()
   parser.add_argument(
     '--output', dest='output', help='Output file to write results to.')
   known_args, pipeline_args = parser.parse_known_args(argv)
   read_query = """(
                 SELECT
                   version,
                   block_hash,
                   block_number
                 FROM
                   `bugquery-public-data.crypto_bitcoin.transactions`
                 WHERE
                   version = 1
                 LIMIT
                   1000000 )
               UNION ALL (
                 SELECT
                   version,
                   block_hash,
                   block_number
                 FROM
                   `bigquery-public-data.crypto_bitcoin.transactions`
                 WHERE
                   version = 2
                 LIMIT
                   1000 ) ;"""
   p = beam.Pipeline(options=PipelineOptions(pipeline_args))
   (p
   | 'Read from BigQuery' >> beam.io.ReadFromBigQuery(query=read_query, use_standard_sql=True)
   | "Add Hotkey" >> beam.Map(lambda elem: (elem["version"], elem))
   | "Groupby" >> beam.GroupByKey()
   | 'Print' >>  beam.ParDo(ReadGBK())
   | 'Sink' >>  WriteToText(known_args.output))

   result = p.run()

if __name__ == '__main__':
 logger = logging.getLogger().setLevel(logging.INFO)
 run()

EOF_CP



export PROJECT_ID=$(gcloud config get-value project)
gsutil mb -l US gs://$PROJECT_ID


# Attempt to launch the pipeline
python3 my_pipeline.py \
  --project=${PROJECT_ID} \
  --region=$REGION \
  --tempLocation=gs://$PROJECT_ID/temp/ \
  --runner=DataflowRunner


# Launch the pipeline
python3 my_pipeline.py \
  --project=${PROJECT_ID} \
  --region=$REGION \
  --output gs://$PROJECT_ID/results/prefix \
  --tempLocation=gs://$PROJECT_ID/temp/ \
  --max_num_workers=5 \
  --runner=DataflowRunner


# Launch the pipeline
python3 my_pipeline.py \
  --project=${PROJECT_ID} \
  --region=$REGION \
  --output gs://$PROJECT_ID/results/prefix \
  --tempLocation=gs://$PROJECT_ID/temp/ \
  --max_num_workers=5 \
  --runner=DataflowRunner

sleep 300



cat > my_pipeline.py <<'EOF_CP'
import argparse
import logging
import argparse, logging, os
import apache_beam as beam
from apache_beam.io import WriteToText
from apache_beam.options.pipeline_options import PipelineOptions
class ReadGBK(beam.DoFn):
 def process(self, e):
   k, elems = e
   for v in elems:
     logging.info(f"the element is {v}")
     yield v
def run(argv=None):
   parser = argparse.ArgumentParser()
   parser.add_argument(
     '--output', dest='output', help='Output file to write results to.')
   known_args, pipeline_args = parser.parse_known_args(argv)
   read_query = """(
                 SELECT
                   version,
                   block_hash,
                   block_number
                 FROM
                   `bigquery-public-data.crypto_bitcoin.transactions`
                 WHERE
                   version = 1
                 LIMIT
                   1000000 )
               UNION ALL (
                 SELECT
                   version,
                   block_hash,
                   block_number
                 FROM
                   `bigquery-public-data.crypto_bitcoin.transactions`
                 WHERE
                   version = 2
                 LIMIT
                   1000 ) ;"""
   p = beam.Pipeline(options=PipelineOptions(pipeline_args))
   (p
   | 'Read from BigQuery' >> beam.io.ReadFromBigQuery(query=read_query, use_standard_sql=True)
   | "Add Hotkey" >> beam.Map(lambda elem: (elem["version"], elem))
   | "Groupby" >> beam.GroupByKey()
   | 'Print' >>  beam.ParDo(ReadGBK())
   | 'Sink' >>  WriteToText(known_args.output))
   result = p.run()
if __name__ == '__main__':
 logger = logging.getLogger().setLevel(logging.INFO)
 run()

EOF_CP



export PROJECT_ID=$(gcloud config get-value project)
gsutil mb -l US gs://$PROJECT_ID


python3 my_pipeline.py \
  --project=${PROJECT_ID} \
  --region=$REGION \
  --output gs://$PROJECT_ID/results/prefix \
  --tempLocation=gs://$PROJECT_ID/temp/ \
  --max_num_workers=5 \
  --runner=DataflowRunner


sleep 400 

echo "LAB Completed, please go to Data flow -> Logs -> Bigquery Load Jobs -> select US and open command line"

