import { notFound } from "next/navigation";
import { TopBar } from "@/components/TopBar";
import { LessonClient } from "@/components/LessonClient";
import { parseFeedbackWrong, parseOptions, prisma } from "@/lib/prisma";

export const dynamic = "force-dynamic";

export default async function MissionPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;

  const mission = await prisma.mission.findUnique({
    where: { slug },
    include: {
      questions: { orderBy: { order: "asc" } },
      module: { include: { trail: true } },
    },
  });

  if (!mission) notFound();

  const formatted = {
    slug: mission.slug,
    title: mission.title,
    intro: mission.intro,
    type: mission.type,
    xpReward: mission.xpReward,
    questions: mission.questions.map((q) => ({
      id: q.id,
      question: q.question,
      options: parseOptions(q.options),
      correctOptionId: q.correctOptionId,
      feedbackCorrect: q.feedbackCorrect,
      feedbackWrong: parseFeedbackWrong(q.feedbackWrong),
      verseRef: q.verseRef,
    })),
  };

  return (
    <div className="min-h-dvh bg-surface">
      <TopBar
        backHref={`/trilha/${mission.module.trail.slug}`}
        title={mission.title}
        subtitle={mission.module.trail.title}
      />
      <LessonClient mission={formatted} trailSlug={mission.module.trail.slug} />
    </div>
  );
}
