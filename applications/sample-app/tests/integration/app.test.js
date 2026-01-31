const request = require('supertest');
const app = require('../../src/index');

describe('API Integration Tests', () => {
  describe('GET /', () => {
    it('should return welcome message', async () => {
      const res = await request(app).get('/');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('message');
      expect(res.body).toHaveProperty('day', '2/95');
    });
  });

  describe('GET /health', () => {
    it('should return health status', async () => {
      const res = await request(app).get('/health');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('status', 'healthy');
      expect(res.body).toHaveProperty('timestamp');
    });
  });

  describe('GET /api/v1/status', () => {
    it('should return service status', async () => {
      const res = await request(app).get('/api/v1/status');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('status', 'operational');
      expect(res.body).toHaveProperty('day', 2);
    });
  });

  describe('GET /info', () => {
    it('should return application info', async () => {
      const res = await request(app).get('/info');
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('app');
      expect(res.body).toHaveProperty('infrastructure');
    });
  });

  describe('GET /nonexistent', () => {
    it('should return 404 for unknown routes', async () => {
      const res = await request(app).get('/nonexistent');
      expect(res.statusCode).toBe(404);
      expect(res.body).toHaveProperty('error', 'Not Found');
    });
  });
});
