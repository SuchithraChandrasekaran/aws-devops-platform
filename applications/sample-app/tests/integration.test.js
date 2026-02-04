const request = require('supertest');
const app = require('../src/app');

describe('Integration Tests', () => {

	  describe('Health Check Integration', () => {
		      test('should return healthy status with all fields', async () => {
			            const response = await request(app).get('/health');

			            expect(response.status).toBe(200);
			            expect(response.body).toEqual({
					            status: 'healthy',
					            timestamp: expect.any(String),
					            uptime: expect.any(Number)
					          });
			          });
		    });

	  describe('Readiness Check Integration', () => {
		      test('should confirm app is ready with timestamp', async () => {
			            const response = await request(app).get('/ready');

			            expect(response.status).toBe(200);
			            expect(response.body).toEqual({
					            ready: true,
					            timestamp: expect.any(String)
					          });
			          });
		    });

	  describe('Sequential Requests', () => {
		      test('should handle multiple concurrent requests without error', async () => {
			            const responses = await Promise.all([
					            request(app).get('/'),
					            request(app).get('/health'),
					            request(app).get('/ready'),
					            request(app).get('/api/info'),
					            request(app).get('/metrics')
					          ]);

			            responses.forEach(res => {
					            expect(res.status).toBe(200);
					          });
			          });
		    });

	  describe('404 Integration', () => {
		      test('should return 404 for unknown routes', async () => {
			            const response = await request(app).get('/nonexistent');

			            expect(response.status).toBe(404);
			            expect(response.body).toEqual({ error: 'Not Found' });
			          });
		    });
});
