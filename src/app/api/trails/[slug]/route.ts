import { NextResponse } from "next/server";
import { parseFeedbackWrong, parseOptions, prisma } from "@/lib/prisma";

export async function GET(
  _request: Request,
  { params }: { params: Promise<{ slug: string }> },
) {
  const { slug } = await params;

  const trail = await prisma.trail.findUnique({
    where: { slug },
    include: {
      modules: {
        include: {
          missions: {
            include: {
              questions: { orderBy: { order: "asc" } },
            },
            orderBy: { order: "asc" },
          },
        },
        orderBy: { order: "asc" },
      },
    },
  });

  if (!trail) {
    return NextResponse.json({ error: "Trilha não encontrada" }, { status: 404 });
  }

  const formatted = {
    ...trail,
    modules: trail.modules.map((mod) => ({
      ...mod,
      missions: mod.missions.map((mission) => ({
        ...mission,
        questions: mission.questions.map((q) => ({
          ...q,
          options: parseOptions(q.options),
          feedbackWrong: parseFeedbackWrong(q.feedbackWrong),
        })),
      })),
    })),
  };

  const allMissionSlugs = trail.modules.flatMap((m) =>
    m.missions.map((mission) => mission.slug),
  );

  return NextResponse.json({ trail: formatted, allMissionSlugs });
}
