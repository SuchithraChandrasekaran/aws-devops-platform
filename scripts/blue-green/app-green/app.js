const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'application/json'});
  res.end(JSON.stringify({
    version: 'v2',
    environment: 'green',
    message: 'Hello from Green deployment - new features here',
    timestamp: new Date().toISOString()
  }));
});

server.listen(3000, () => {
  console.log('Green app v2 running on port 3000');
});
