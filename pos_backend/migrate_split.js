const db = require('./db');
async function migrate() {
  try {
     await db.query(`ALTER TABLE bills ALTER COLUMN payment_method TYPE VARCHAR(255)`);
     console.log("Migration done");
     process.exit(0);
  } catch(e) { console.error(e); process.exit(1); }
}
migrate();
