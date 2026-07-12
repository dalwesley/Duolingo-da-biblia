import "dotenv/config";
import { PrismaBetterSqlite3 } from "@prisma/adapter-better-sqlite3";
import { PrismaClient } from "../src/generated/prisma/client";
import { genesisTrail } from "./seed-data/genesis";
import { exodusTrail } from "./seed-data/exodus";
import { lockedTrails } from "./seed-data/locked-trails";

const url = process.env.DATABASE_URL ?? "file:./prisma/dev.db";
const adapter = new PrismaBetterSqlite3({ url });
const prisma = new PrismaClient({ adapter });

async function seedTrailContent(
  trailData: typeof genesisTrail,
  order: number,
  unlockAfter: string | null = null,
  color = "#6C5CE7",
) {
  const trail = await prisma.trail.create({
    data: {
      slug: trailData.slug,
      title: trailData.title,
      description: trailData.description,
      icon: trailData.icon,
      order,
      unlockAfter,
      comingSoon: false,
      color,
    },
  });

  for (const [moduleIndex, mod] of trailData.modules.entries()) {
    const dbModule = await prisma.module.create({
      data: {
        trailId: trail.id,
        order: moduleIndex + 1,
        title: mod.title,
        icon: mod.icon,
      },
    });

    for (const [missionIndex, mission] of mod.missions.entries()) {
      await prisma.mission.create({
        data: {
          moduleId: dbModule.id,
          slug: mission.slug,
          order: missionIndex + 1,
          title: mission.title,
          intro: mission.intro,
          type: mission.type,
          xpReward: mission.xpReward,
          questions: {
            create: mission.questions.map((q, qi) => ({
              order: qi + 1,
              type: "multiple_choice",
              question: q.question,
              options: JSON.stringify(q.options),
              correctOptionId: q.correctOptionId,
              feedbackCorrect: q.feedbackCorrect,
              feedbackWrong: JSON.stringify(q.feedbackWrong),
              verseRef: q.verseRef ?? null,
            })),
          },
        },
      });
    }
  }

  return trail;
}

async function main() {
  console.log("🌱 Seeding database...");

  await prisma.question.deleteMany();
  await prisma.mission.deleteMany();
  await prisma.module.deleteMany();
  await prisma.trail.deleteMany();

  const genesis = await seedTrailContent(genesisTrail, 1, null, "#6C5CE7");
  console.log(`✅ Trail "${genesis.title}" — conteúdo completo`);

  const exodus = await seedTrailContent(exodusTrail, 2, "genesis-1-11", exodusTrail.color);
  console.log(`✅ Trail "${exodus.title}" — conteúdo completo`);

  for (const locked of lockedTrails) {
    await prisma.trail.create({
      data: {
        slug: locked.slug,
        title: locked.title,
        description: locked.description,
        icon: locked.icon,
        order: locked.order,
        unlockAfter: locked.unlockAfter,
        comingSoon: locked.comingSoon,
        color: locked.color,
      },
    });
    console.log(`🔒 Trail "${locked.title}" — bloqueada (em breve)`);
  }

  const missions = await prisma.mission.count();
  const questions = await prisma.question.count();
  const trails = await prisma.trail.count();
  console.log(`\n📊 ${trails} trilhas · ${missions} missões · ${questions} perguntas`);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
