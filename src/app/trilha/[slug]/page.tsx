import { notFound } from "next/navigation";
import { AppShell } from "@/components/AppShell";
import { TrailMap } from "@/components/TrailMap";
import { TrailPageHeader } from "@/components/TrailPageHeader";
import { getTrailBySlug } from "@/lib/db-trails";
import { getTrailMissionSlugs } from "@/lib/trails";

export const dynamic = "force-dynamic";

export default async function TrailPage({
  params,
}: {
  params: Promise<{ slug: string }>;
}) {
  const { slug } = await params;
  const trail = await getTrailBySlug(slug);

  if (!trail) notFound();

  const allMissionSlugs = getTrailMissionSlugs(trail);

  if (allMissionSlugs.length === 0) {
    return (
      <AppShell backHref="/trilhas" title={trail.title} showNav>
        <div className="px-4 py-12 text-center">
          <span className="text-6xl">{trail.icon}</span>
          <h1 className="mt-4 text-2xl font-extrabold text-text">
            Em breve
          </h1>
          <p className="mt-2 text-text-muted">{trail.description}</p>
        </div>
      </AppShell>
    );
  }

  return (
    <AppShell backHref="/trilhas" title={trail.title} subtitle={trail.description}>
      <div className="px-4 pb-8">
        <TrailPageHeader trail={trail} allMissionSlugs={allMissionSlugs} />
        <TrailMap
          trailSlug={trail.slug}
          modules={trail.modules}
          allMissionSlugs={allMissionSlugs}
          trailColor={trail.color}
        />
      </div>
    </AppShell>
  );
}
