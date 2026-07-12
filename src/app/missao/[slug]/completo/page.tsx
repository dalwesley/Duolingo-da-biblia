import { CelebrationClient } from "@/components/CelebrationClient";
import { TopBar } from "@/components/TopBar";

export default async function MissionCompletePage({
  params,
  searchParams,
}: {
  params: Promise<{ slug: string }>;
  searchParams: Promise<{
    xp?: string;
    correct?: string;
    total?: string;
    trail?: string;
  }>;
}) {
  const { slug } = await params;
  const sp = await searchParams;

  const xp = Number(sp.xp ?? 50);
  const correct = Number(sp.correct ?? 0);
  const total = Number(sp.total ?? 1);
  const trailSlug = sp.trail ?? "genesis-1-11";

  return (
    <div className="min-h-dvh bg-surface">
      <TopBar title="Missão completa!" subtitle="Parabéns!" />
      <CelebrationClient
        missionSlug={slug}
        xp={xp}
        correct={correct}
        total={total}
        trailSlug={trailSlug}
      />
    </div>
  );
}
