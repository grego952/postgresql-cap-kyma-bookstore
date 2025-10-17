const cds = require('@sap/cds');
const { Client } = require('pg');

// Add a custom endpoint to demonstrate PostgreSQL connectivity
cds.on('served', () => {
  const app = cds.app;
  const path = require('path');
  
  // Serve static frontend
  app.use('/app', require('express').static(path.join(__dirname, 'app')));
  
  // Redirect root to app
  app.get('/', (req, res) => {
    res.redirect('/app');
  });
  
  // Custom endpoint that bypasses CAP ORM and uses direct PostgreSQL
  app.get('/api/test-postgres', async (req, res) => {
    const client = new Client({
      host: 'localhost',
      port: 5432,
      database: 'capdb',
      user: 'capuser',
      password: '',
      ssl: false
    });
    
    try {
      await client.connect();
      console.log('✅ Direct PostgreSQL connection successful');
      
      const result = await client.query(`
        SELECT 
          title, 
          author, 
          price, 
          currency_code 
        FROM sap_capire_bookstore_books 
        LIMIT 3
      `);
      
      await client.end();
      
      res.json({
        success: true,
        message: "🎯 PostgreSQL + Kyma Integration Working!",
        books: result.rows,
        connection_info: {
          host: 'localhost',
          database: 'capdb',
          ssl_mode: "disabled"
        }
      });
      
    } catch (error) {
      if (client) await client.end();
      console.error('❌ PostgreSQL connection failed:', error.message);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  });
});

// Start the CAP server
module.exports = cds.server;