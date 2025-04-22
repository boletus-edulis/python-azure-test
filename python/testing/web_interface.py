#!/usr/bin/env python

from azure.identity import DefaultAzureCredential
from azure.mgmt.resourcegraph import ResourceGraphClient
from azure.mgmt.resourcegraph.models import (
    QueryRequest,
    QueryRequestOptions,
    ResultFormat,
)

# Acquire a credential object
token_credential = DefaultAzureCredential()

resource_graph_client = ResourceGraphClient(credential=token_credential)

query = QueryRequest(
    query="", options=QueryRequestOptions(result_format=ResultFormat.OBJECT_ARRAY)
)

query_result = resource_graph_client.resources(query)

if __name__ == "__main__":
    main()
