const app = require('../src/app');

describe('App Module', () => {
	  test('should export an express app', () => {
		      expect(app).toBeDefined();
		      expect(typeof app).toBe('function');
		    });
});
