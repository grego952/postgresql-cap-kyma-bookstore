const cds = require('@sap/cds');
const fs = require('fs');
const path = require('path');

async function initializeDatabase() {
  try {
    console.log('🚀 Starting database initialization...');
    
    // Load the model
    console.log('📄 Loading CDS model...');
    const model = await cds.load(['db/schema.cds', 'srv/services.cds']);
    
    // Use the same database configuration as the main app
    // CDS_REQUIRES is set by start-postgres.sh with correct PostgreSQL credentials
    console.log('📦 Connecting to database...');
    const db = await cds.connect.to('db');
    
    // Deploy schema using full deployment with explicit options
    console.log('🏗️  Deploying database schema and services...');
    await cds.deploy(model, { 
      to: db,
      with_mocks: false,
      dry: false
    });
    
    // Load initial data
    console.log('📊 Loading initial data...');
    
    // Check if data files exist
    const dataDir = path.join(__dirname, 'db', 'data');
    if (fs.existsSync(dataDir)) {
      console.log('📁 Found data directory, loading CSV files...');
      
      // Check if data already exists
      const existingCurrencies = await db.run(SELECT.from('sap_common_Currencies'));
      if (existingCurrencies.length === 0) {
        console.log('💰 Loading currencies...');
        const currencies = [
          { code: 'EUR', symbol: '€', minorUnit: 2, name: 'Euro', descr: 'Euro' },
          { code: 'USD', symbol: '$', minorUnit: 2, name: 'US Dollar', descr: 'US Dollar' },
          { code: 'PLN', symbol: 'zł', minorUnit: 2, name: 'Polish Zloty', descr: 'Polish Zloty' }
        ];
        await db.run(INSERT.into('sap_common_Currencies').entries(currencies));
      } else {
        console.log('💰 Currencies already exist, skipping...');
      }
      
      // Check if books already exist
      const existingBooks = await db.run(SELECT.from('sap_capire_bookstore_Books'));
      if (existingBooks.length === 0) {
        console.log('📚 Loading books...');
        const books = [
          {
            ID: '11111111-1111-1111-1111-111111111111',
            title: 'Harry Potter and the Philosopher\'s Stone',
            author: 'J.K. Rowling',
            genre: 'Fantasy',
            price: 29.99,
            currency_code: 'EUR',
            stock: 50,
            description: 'The first book in the Harry Potter series',
            publisher: 'Bloomsbury',
            publishedAt: '1997-06-26',
            isbn: '9780747532699',
            createdAt: new Date().toISOString(),
            createdBy: 'system'
          },
          {
            ID: '22222222-2222-2222-2222-222222222222',
            title: 'A Game of Thrones',
            author: 'George R.R. Martin',
            genre: 'Fantasy',
            price: 35.50,
            currency_code: 'EUR',
            stock: 25,
            description: 'The first book in A Song of Ice and Fire series',
            publisher: 'Bantam Spectra',
            publishedAt: '1996-08-01',
            isbn: '9780553103540',
            createdAt: new Date().toISOString(),
            createdBy: 'system'
          },
          {
            ID: '33333333-3333-3333-3333-333333333333',
            title: 'The Last Wish',
            author: 'Andrzej Sapkowski',
            genre: 'Fantasy',
            price: 28.00,
            currency_code: 'EUR',
            stock: 30,
            description: 'First book in The Witcher series',
            publisher: 'superNOWA',
            publishedAt: '1993-01-01',
            isbn: '9788375780642',
            createdAt: new Date().toISOString(),
            createdBy: 'system'
          }
        ];
        
        await db.run(INSERT.into('sap_capire_bookstore_Books').entries(books));
      } else {
        console.log('📚 Books already exist, skipping...');
      }
      
      // Check if authors already exist
      const existingAuthors = await db.run(SELECT.from('sap_capire_bookstore_Authors'));
      if (existingAuthors.length === 0) {
        console.log('✍️  Loading authors...');
        const authors = [
          {
            ID: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
            name: 'J.K. Rowling',
            birthDate: '1965-07-31',
            nationality: 'British',
            biography: 'British author best known for the Harry Potter series',
            createdAt: new Date().toISOString(),
            createdBy: 'system'
          },
          {
            ID: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
            name: 'George R.R. Martin',
            birthDate: '1948-09-20',
            nationality: 'American',
            biography: 'American novelist and short story writer known for A Song of Ice and Fire',
            createdAt: new Date().toISOString(),
            createdBy: 'system'
          }
        ];
        
        await db.run(INSERT.into('sap_capire_bookstore_Authors').entries(authors));
      } else {
        console.log('✍️  Authors already exist, skipping...');
      }
    }
    
    // Debug: Check what tables were created
    console.log('🔍 Checking created tables...');
    const tables = await db.run("SELECT name FROM sqlite_master WHERE type='table'");
    console.log('📋 Available tables:', tables.map(t => t.name));
    
    console.log('✅ Database initialization completed successfully!');    
    process.exit(0);
    
  } catch (error) {
    console.error('❌ Database initialization failed:', error);
    process.exit(1);
  }
}

// Run initialization
initializeDatabase();