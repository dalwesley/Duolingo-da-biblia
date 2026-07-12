/**
 * Importa perguntas do dataset BIBLE (HuggingFace) para o banco.
 * Uso futuro: npm run db:import-bible
 *
 * Requer: pip install datasets (ou fetch manual do JSON)
 */
import "dotenv/config";
import { PrismaBetterSqlite3 } from "@prisma/adapter-better-sqlite3";
import { PrismaClient } from "../src/generated/prisma/client";

const url = process.env.DATABASE_URL ?? "file:./prisma/dev.db";
const adapter = new PrismaBetterSqlite3({ url });
const prisma = new PrismaClient({ adapter });

async function main() {
  console.log("📥 Import BIBLE dataset — placeholder");
  console.log("Dataset: https://huggingface.co/datasets/MushroomGecko/BIBLE");
  console.log("");
  console.log("Por enquanto, use o conteúdo curado em prisma/seed-data/genesis.ts");
  console.log("Para importar: filtre por category=Genesis, traduza para PT,");
  console.log("associe a missões existentes ou crie novas via IA organizadora.");

  const count = await prisma.question.count();
  console.log(`\nPerguntas atuais no banco: ${count}`);
}

main()
  .finally(() => prisma.$disconnect());
