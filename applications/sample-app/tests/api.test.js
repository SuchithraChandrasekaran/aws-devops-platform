const request = require('supertest');
const app = require('../src/app');

describe('API Tests', () => {

	  describe('GET /', () => {
		      test('should return 200', async () => {
			            const response = await request(app).get('/');
			            expect(response.status).toBe(200);
			          });

		      test('should return JSON with Hello message', async () => {
			            const response = await request(app).get('/');
			            expect(response.body).toEqual({ message: 'Hello' });
			          });
		    });

	  describe('GET /health', () => {
		      test('should return 200', async () => {
			            const response = await request(app).get('/health');
			            expect(response.status).toBe(200);
			          });

		      test('should return JSON content type', async () => {
			            const response = await request(app).get('/health');
			            expect(response.headers['content-type']).toMatch(/json/);
			          });

		      test('should return status, timestamp, and uptime', async () => {
			            const response = await request(app).get('/health');
			            expect(response.body).toEqual({
					            status: 'healthy',
					            timestamp: expect.any(String),
					            uptime: expect.any(Number)
					          });
			          });

		      test('should have uptime as a number >= 0', async () => {
			            const response = await request(app).get('/health');
			            expect(response.body.uptime).toBeGreaterThanOrEqual(0);
			          });
		    });

	  describe('GET /ready', () => {
		      test('should return 200', async () => {
			            const response = await request(app).get('/ready');
			            expect(response.status).toBe(200);
			          });

		      test('should return ready true and a timestamp', async () => {
			            const response = await request(app).get('/ready');
			            expect(response.body).toEqual({
					            ready: true,
					            timestamp: expect.any(String)
					          });
			          });
		    });

	  describe('GET /api/info', () => {
		      test('should return 200', async () => {
			            const response = await request(app).get('/api/info');
			            expect(response.status).toBe(200);
			          });

		      test('should return version and endpoints list', async () => {
			            const response = await request(app).get('/api/info');
			            expect(response.body).toEqual({
					            version: '1.0.0',
					            endpoints: ['/', '/health', '/ready', '/api/info']
					          });
			          });
		    });

	  describe('GET /metrics', () => {
		      test('should return 200', async () => {
			            const response = await request(app).get('/metrics');
			            expect(response.status).toBe(200);
			          });

		      test('should return uptime, timestamp, and memory object', async () => {
			            const response = await request(app).get('/metrics');
			            expect(response.body).toEqual({
					            uptime: expect.any(Number),
					            timestamp: expect.any(String),
					            memory: expect.any(Object)
					          });
			          });

		      test('memory should contain rss and heapUsed', async () => {
			            const response = await request(app).get('/metrics');
			            expect(response.body.memory).toHaveProperty('rss');
			            expect(response.body.memory).toHaveProperty('heapUsed');
			          });
		    });

	  describe('404 Handler', () => {
		      test('should return 404 for GET on unknown route', async () => {
			            const response = await request(app).get('/nonexistent');
			            expect(response.status).toBe(404);
			            expect(response.body).toEqual({ error: 'Not Found' });
			          });

		      test('should return 404 for POST on unknown route', async () => {
			            const response = await request(app).post('/nonexistent');
			            expect(response.status).toBe(404);
			            expect(response.body).toEqual({ error: 'Not Found' });
			          });
		    });
});
