import { NextResponse } from "next/server";
import { parseFeedbackWrong, parseOptions, prisma } from "@/lib/prisma";

export async function GET(
  _request: Request,
  { params }: { params: Promise<{ slug: string }> },
) {
  const { slug } = await params;

  const mission = await prisma.mission.findUnique({
    where: { slug },
    include: {
      questions: { orderBy: { order: "asc" } },
      module: {
        include: {
          trail: true,
          missions: { select: { slug: true }, orderBy: { order: "asc" } },
        },
      },
    },
  });

  if (!mission) {
    return NextResponse.json({ error: "Missão não encontrada" }, { status: 404 });
  }

  const allMissionSlugs = await prisma.mission.findMany({
    where: { module: { trailId: mission.module.trail.id } },
    orderBy: [{ module: { order: "asc" } }, { order: "asc" }],
    select: { slug: true },
  });

  return NextResponse.json({
    mission: {
      ...mission,
      questions: mission.questions.map((q) => ({
        ...q,
        options: parseOptions(q.options),
        feedbackWrong: parseFeedbackWrong(q.feedbackWrong),
      })),
    },
    trailSlug: mission.module.trail.slug,
    allMissionSlugs: allMissionSlugs.map((m) => m.slug),
  });
}
