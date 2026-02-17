#!/usr/bin/env python3
"""
Custom Application Metrics Exporter - Day 19
Exposes custom metrics in Prometheus format
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import random
import time

class MetricsHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/metrics':
            metrics = self.generate_metrics()
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; version=0.0.4')
            self.end_headers()
            self.wfile.write(metrics.encode())
        else:
            self.send_response(404)
            self.end_headers()
    
    def generate_metrics(self):
        """Generate sample application metrics"""
        timestamp = int(time.time() * 1000)
        
        metrics = [
            '# HELP myapp_requests_total Total number of requests',
            '# TYPE myapp_requests_total counter',
            f'myapp_requests_total{{service="api",method="GET"}} {random.randint(1000, 5000)}',
            f'myapp_requests_total{{service="api",method="POST"}} {random.randint(500, 2000)}',
            '',
            '# HELP myapp_request_duration_seconds Request duration in seconds',
            '# TYPE myapp_request_duration_seconds histogram',
            f'myapp_request_duration_seconds_bucket{{le="0.1"}} {random.randint(800, 1000)}',
            f'myapp_request_duration_seconds_bucket{{le="0.5"}} {random.randint(1500, 2000)}',
            f'myapp_request_duration_seconds_bucket{{le="1.0"}} {random.randint(2000, 3000)}',
            f'myapp_request_duration_seconds_bucket{{le="+Inf"}} {random.randint(3000, 4000)}',
            f'myapp_request_duration_seconds_sum {random.uniform(100, 500):.2f}',
            f'myapp_request_duration_seconds_count {random.randint(3000, 4000)}',
            '',
            '# HELP myapp_errors_total Total number of errors',
            '# TYPE myapp_errors_total counter',
            f'myapp_errors_total{{service="api",type="4xx"}} {random.randint(10, 50)}',
            f'myapp_errors_total{{service="api",type="5xx"}} {random.randint(0, 10)}',
            '',
            '# HELP myapp_active_users Current number of active users',
            '# TYPE myapp_active_users gauge',
            f'myapp_active_users {random.randint(50, 200)}',
            '',
            '# HELP myapp_database_connections Current database connections',
            '# TYPE myapp_database_connections gauge',
            f'myapp_database_connections{{pool="read"}} {random.randint(5, 20)}',
            f'myapp_database_connections{{pool="write"}} {random.randint(2, 10)}',
            '',
            '# HELP myapp_cache_hit_ratio Cache hit ratio',
            '# TYPE myapp_cache_hit_ratio gauge',
            f'myapp_cache_hit_ratio {random.uniform(0.75, 0.95):.2f}',
            ''
        ]
        
        return '\n'.join(metrics)
    
    def log_message(self, format, *args):
        """Suppress default logging"""
        pass

if __name__ == '__main__':
    port = 8000
    server = HTTPServer(('0.0.0.0', port), MetricsHandler)
    print(f"Custom App Exporter running on port {port}")
    print("Metrics available at http://localhost:8000/metrics")
    server.serve_forever()
