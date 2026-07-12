import "dotenv/config";
import { PrismaBetterSqlite3 } from "@prisma/adapter-better-sqlite3";
import { PrismaClient } from "@/generated/prisma/client";

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };

function createPrismaClient() {
  const url = process.env.DATABASE_URL ?? "file:./prisma/dev.db";
  const adapter = new PrismaBetterSqlite3({ url });
  return new PrismaClient({ adapter });
}

export const prisma = globalForPrisma.prisma ?? createPrismaClient();

if (process.env.NODE_ENV !== "production") {
  globalForPrisma.prisma = prisma;
}

export type QuestionOption = { id: string; text: string };

export function parseOptions(json: string): QuestionOption[] {
  return JSON.parse(json) as QuestionOption[];
}

export function parseFeedbackWrong(json: string): Record<string, string> {
  return JSON.parse(json) as Record<string, string>;
}
