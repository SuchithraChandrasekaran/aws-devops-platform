// Basic tests for the sample application
const request = require('supertest');
const app = require('../src/index');

describe('Sample App Tests', () => {
  test('GET / should return hello message', async () => {
    const response = await request(app)
      .get('/')
      .expect('Content-Type', /json/)
      .expect(200);
    
    expect(response.body).toHaveProperty('message');
    expect(response.body.message).toContain('Hello');
  });

  test('GET /health should return healthy status', async () => {
    const response = await request(app)
      .get('/health')
      .expect(200);
    
    expect(response.body).toHaveProperty('status');
    expect(response.body.status).toBe('healthy');
  });

  test('GET /metrics should return metrics', async () => {
    const response = await request(app)
      .get('/metrics')
      .expect(200);
    
    expect(response.body).toHaveProperty('uptime');
    expect(response.body).toHaveProperty('timestamp');
  });

  test('GET /api/info should return API information', async () => {
    const response = await request(app)
      .get('/api/info')
      .expect(200);
    
    expect(response.body).toHaveProperty('version');
    expect(response.body).toHaveProperty('endpoints');
  });

  test('GET /ready should return ready status', async () => {
    const response = await request(app)
      .get('/ready')
      .expect(200);
    
    expect(response.body).toHaveProperty('ready');
    expect(response.body.ready).toBe(true);
  });

  test('GET /nonexistent should return 404', async () => {
    const response = await request(app)
      .get('/nonexistent')
      .expect(404);
    
    expect(response.body).toHaveProperty('error');
    expect(response.body.error).toBe('Not Found');
  });
});