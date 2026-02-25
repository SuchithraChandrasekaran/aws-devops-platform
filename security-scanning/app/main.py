"""
Sample Flask application for security scanning
"""
from flask import Flask, request, jsonify
import os

app = Flask(__name__)

@app.route('/')
def home():
    return jsonify({'message': 'Hello World', 'status': 'healthy'})

@app.route('/health')
def health():
    return jsonify({'status': 'ok'})

@app.route('/api/data')
def get_data():
    # Sample endpoint
    return jsonify({'data': 'Sample data'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
