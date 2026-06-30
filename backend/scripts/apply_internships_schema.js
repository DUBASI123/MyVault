import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import path from 'path';
import pkg from 'pg';
const { Client } = pkg;
import dotenv from 'dotenv';
dotenv.config();

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const DB_URL = process.env.DATABASE_URL_DIRECT || process.env.DATABASE_URL;

async function runFile(client, filename) {
  const sql = readFileSync(path.join(__dirname, filename), 'utf-8');
  try {
    await client.query(sql);
    console.log(`\u2705 ${filename} applied successfully!`);
  } catch (err) {
    console.error(`\u274c Error applying ${filename}:`, err.message);
    throw err;
  }
}

async function main() {
  console.log('Connecting to Supabase...');
  const client = new Client({ connectionString: DB_URL, ssl: { rejectUnauthorized: false } });
  await client.connect();
  console.log('Connected!\n');

  try {
    await runFile(client, 'internships_schema.sql');
    await runFile(client, 'placements_schema.sql');
    console.log('\n\u2705 All schemas applied!');
  } finally {
    await client.end();
  }
}

main().catch(err => {
  console.error('Fatal error:', err);
  process.exit(1);
});
