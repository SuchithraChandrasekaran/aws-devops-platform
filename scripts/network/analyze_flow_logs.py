#!/usr/bin/env python3
"""
VPC Flow Logs Analyzer - Day 24
Analyze VPC Flow Logs for security insights
"""

import boto3
import time
from collections import defaultdict

logs = boto3.client(
    'logs',
    endpoint_url='http://localhost:4566',
    region_name='us-east-1',
    aws_access_key_id='test',
    aws_secret_access_key='test'
)

def query_flow_logs(log_group, hours=1):
    """Query VPC Flow Logs"""
    query = """
    fields @timestamp, srcAddr, dstAddr, srcPort, dstPort, protocol, action
    | filter action = "REJECT"
    | sort @timestamp desc
    | limit 100
    """
    
    start_time = int((time.time() - hours * 3600) * 1000)
    end_time = int(time.time() * 1000)
    
    try:
        response = logs.start_query(
            logGroupName=log_group,
            startTime=start_time,
            endTime=end_time,
            queryString=query
        )
        
        query_id = response['queryId']
        
        # Wait for query to complete
        while True:
            result = logs.get_query_results(queryId=query_id)
            status = result['status']
            
            if status == 'Complete':
                return result['results']
            elif status == 'Failed':
                print(f"Query failed")
                return []
            
            time.sleep(1)
            
    except Exception as e:
        print(f"Error querying logs: {e}")
        return []

def analyze_rejected_traffic(log_group):
    """Analyze rejected traffic patterns"""
    print("="*70)
    print("VPC Flow Logs Analysis - Rejected Traffic")
    print("="*70)
    
    try:
        # Get recent flow log entries
        response = logs.filter_log_events(
            logGroupName=log_group,
            limit=100
        )
        
        events = response.get('events', [])
        
        if not events:
            print("\nNo flow log events found")
            return
        
        rejected_ips = defaultdict(int)
        rejected_ports = defaultdict(int)
        
        for event in events:
            message = event['message']
            parts = message.split()
            
            if len(parts) >= 13:
                action = parts[12]
                
                if action == 'REJECT':
                    src_ip = parts[3]
                    dst_port = parts[5]
                    
                    rejected_ips[src_ip] += 1
                    rejected_ports[dst_port] += 1
        
        # Top rejected source IPs
        print("\nTop Rejected Source IPs:")
        print("-" * 70)
        for ip, count in sorted(rejected_ips.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  {ip}: {count} attempts")
        
        # Top rejected destination ports
        print("\nTop Rejected Destination Ports:")
        print("-" * 70)
        for port, count in sorted(rejected_ports.items(), key=lambda x: x[1], reverse=True)[:10]:
            print(f"  Port {port}: {count} attempts")
        
        print("\n" + "="*70)
        
    except Exception as e:
        print(f"Error analyzing logs: {e}")

if __name__ == '__main__':
    log_group = '/aws/vpc/myapp-flow-logs'
    analyze_rejected_traffic(log_group)
