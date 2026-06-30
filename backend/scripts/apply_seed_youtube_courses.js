// ============================================================
// scripts/apply_seed_youtube_courses.js
// ============================================================
import { PrismaClient } from '@prisma/client';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  const url = process.env.DATABASE_URL || "postgresql://postgres.oawomrlsitttrbulxgyk:jzqqWU5XbrckrIAD@aws-1-ap-south-1.pooler.supabase.com:5432/postgres?sslmode=require";
  
  console.log("Connecting to Database at URL:", url.includes('@') ? url.split('@').pop() : url.substring(0, 30) + "...");
  
  const prisma = new PrismaClient({
    datasources: {
      db: { url }
    }
  });

  try {
    const sqlFilePath = path.join(__dirname, 'seed_youtube_courses.sql');
    console.log(`Reading SQL file from: ${sqlFilePath}`);
    const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');

    console.log("Seeding YouTube courses into production database...");
    
    // 1. Strip comments cleanly
    const cleanSql = sqlContent
      .split('\n')
      .map(line => line.replace(/--.*/g, "")) // strip single-line comments
      .join('\n')
      .replace(/\/\*[\s\S]*?\*\//g, ""); // strip multi-line comments

    // 2. Split statements respecting single and dollar quotes
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

    for (let i = 0; i < cleanStatements.length; i++) {
      const stmt = cleanStatements[i];
      try {
        await prisma.$executeRawUnsafe(stmt);
      } catch (err) {
        console.error(`Error executing statement ${i + 1}:`, stmt.substring(0, 150) + "...");
        console.error(err.message || err);
        throw err;
      }
    }
    
    console.log("🎉 YouTube courses seeded successfully!");
  } catch (error) {
    console.error("❌ Error seeding YouTube courses:", error);
  } finally {
    await prisma.$disconnect();
  }
}

main();
