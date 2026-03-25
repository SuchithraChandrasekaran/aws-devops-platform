const http = require('http');

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'application/json'});
  res.end(JSON.stringify({
    version: 'v1',
    environment: 'blue',
    message: 'Hello from Blue deployment',
    timestamp: new Date().toISOString()
  }));
});

server.listen(3000, () => {
  console.log('Blue app v1 running on port 3000');
});
