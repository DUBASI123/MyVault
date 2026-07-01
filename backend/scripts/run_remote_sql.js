import pkg from 'pg';
const { Client } = pkg;
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const url = "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";

async function executeSqlFile(client, filePath) {
  console.log(`\n--- Executing SQL File: ${path.basename(filePath)} ---`);
  const sql = fs.readFileSync(filePath, 'utf8');
  
  // Clean SQL comments
  const cleanSql = sql
    .split('\n')
    .map(line => line.replace(/--.*/g, "")) // strip single-line comments
    .join('\n')
    .replace(/\/\*[\s\S]*?\*\//g, ""); // strip multi-line comments
    
  // Split statements by semicolon
  const statements = [];
  let current = [];
  let inSingleQuote = false;
  let inDollarQuote = false;

  for (let i = 0; i < cleanSql.length; i++) {
    const char = cleanSql[i];
    const nextChar = cleanSql[i + 1] || '';

    if (char === '$' && nextChar === '$') {
      inDollarQuote = !inDollarQuote;
      current.push('$$');
      i++;
      continue;
    }

    if (char === "'" && !inDollarQuote) {
      if (nextChar === "'") {
        current.push("''");
        i++;
        continue;
      }
      inSingleQuote = !inSingleQuote;
      current.push("'");
      continue;
    }

    if (char === ';' && !inSingleQuote && !inDollarQuote) {
      statements.push(current.join(''));
      current = [];
    } else {
      current.push(char);
    }
  }

  if (current.length > 0) {
    statements.push(current.join(''));
  }

  const cleanStatements = statements
    .map(s => s.trim())
    .filter(s => s.length > 0);

  console.log(`Found ${cleanStatements.length} SQL statements to execute.`);

  for (let i = 0; i < cleanStatements.length; i++) {
    const stmt = cleanStatements[i];
    try {
      await client.query(stmt);
    } catch (err) {
      console.error(`❌ Error executing statement ${i + 1}:`);
      console.error(stmt.substring(0, 150) + "...");
      console.error(err.message);
      throw err;
    }
  }
  console.log(`✅ Finished executing: ${path.basename(filePath)}`);
}

async function main() {
  console.log("Connecting directly via pg to remote Supabase...");
  const client = new Client({ connectionString: url, ssl: { rejectUnauthorized: false } });
  await client.connect();
  console.log("Connected successfully!");

  try {
    // 1. Create internships schemas
    await executeSqlFile(client, path.join(__dirname, 'internships_schema.sql'));
    await executeSqlFile(client, path.join(__dirname, 'placements_schema.sql'));
    
    // 2. Seed YouTube courses
    await executeSqlFile(client, path.join(__dirname, 'seed_youtube_courses.sql'));
    
    // 3. Seed extra 10 courses
    await executeSqlFile(client, path.join(__dirname, 'seed_extra_courses.sql'));
    
    console.log("\n🎉 All SQL schemas and courses (20 total) applied and seeded successfully to remote Supabase!");
  } catch (error) {
    console.error("\n❌ Seeding failed:", error);
  } finally {
    await client.end();
  }
}

main();
