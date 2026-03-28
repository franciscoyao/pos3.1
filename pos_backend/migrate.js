const db = require('./db');

async function migrate() {
  try {
     await db.query(`ALTER TABLE products ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;`);
     await db.query(`ALTER TABLE order_items ADD COLUMN IF NOT EXISTS extras JSONB DEFAULT '[]'::jsonb`);
     await db.query(`
      CREATE TABLE IF NOT EXISTS product_extras (
        id SERIAL PRIMARY KEY,
        product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        price DECIMAL(10, 2) DEFAULT 0
      )
     `);
     console.log("Migration done");
     process.exit(0);
  } catch(e) { 
    console.error(e); 
    process.exit(1); 
  }
}

migrate();
