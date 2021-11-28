import json
import logging
import os

import boto3
from opensearchpy import OpenSearch
from opensearchpy import RequestsHttpConnection
from requests_aws4auth import AWS4Auth
from util import split

host = os.environ["OPENSEARCH_URL"]
region = os.environ["OPENSEARCH_REGION"]

service = "es"
credentials = boto3.Session().get_credentials()
awsauth = AWS4Auth(
    credentials.access_key,
    credentials.secret_key,
    region,
    service,
    session_token=credentials.token,
)

search = OpenSearch(
    hosts=[{"host": host, "port": 443}],
    http_auth=awsauth,
    use_ssl=True,
    verify_certs=True,
    connection_class=RequestsHttpConnection,
)


def es_upload(items, idKey, index):
    for chunk in split(items, 10):
        if len(chunk):
            bulk_file = ""
            for item in chunk:
                logging.info(
                    "add issue %s to ES bulk of %d items", item[idKey], len(chunk)
                )
                bulk_file += (
                    '{ "index" : { "_index" : "'
                    + index
                    + '", "_type" : "_doc", "_id" : "'
                    + item[idKey]
                    + '" }}\n'
                )
                bulk_file += json.dumps(item) + "\n"
            search.bulk(bulk_file)
