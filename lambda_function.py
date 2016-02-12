from __future__ import print_function

import boto3
import logging
import json
from decimal import Decimal

print('Loading function')

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def get_metric_data(name, host_name, timestamp, value, unit):
    return [
                {
                    'MetricName': name,
                    'Dimensions': [
                        {
                            'Name': 'Device',
                            'Value': host_name
                        },
                    ],
                    'Timestamp': timestamp,
                    'Value': Decimal(value),
                    'Unit': unit
                },
            ]

def lambda_handler(event, context):
    logger.info(event)

    # "2016-02-07 05:14:38,22.0,22.0,1871.67,1023\n"
    client = boto3.client('cloudwatch')
    host_name = event["device"];
    for data in event["metrics"].split('\n'):
        items = data.split(',')
        logger.info(items)
        if len(items) != 5:
            continue

        response = client.put_metric_data(
            Namespace='PI_FARM',
            MetricData=get_metric_data('temperature', host_name, items[0], items[2], 'None')
        )
        response = client.put_metric_data(
            Namespace='PI_FARM',
            MetricData=get_metric_data('humidity', host_name, items[0], items[1], 'Percent')
        )
        response = client.put_metric_data(
            Namespace='PI_FARM',
            MetricData=get_metric_data('lux', host_name, items[0], items[3], 'None')
        )
        try:
            response = client.put_metric_data(
                Namespace='PI_FARM',
                MetricData=get_metric_data('moisture', host_name, items[0], round((float(items[4])/1023)*100, 2), 'Percent')
            )
        except:
            logger.info("calculate faild: {0}".format(items[4]))
    return True
