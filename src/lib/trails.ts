export type MissionSummary = {
  slug: string;
  title: string;
  type: string;
  xpReward: number;
  order: number;
};

export type ModuleSummary = {
  title: string;
  icon: string;
  missions: MissionSummary[];
};

export type TrailSummary = {
  slug: string;
  title: string;
  description: string;
  icon: string;
  order: number;
  unlockAfter: string | null;
  comingSoon: boolean;
  color: string;
  modules: ModuleSummary[];
};

export function getTrailMissionSlugs(trail: TrailSummary): string[] {
  return trail.modules.flatMap((m) => m.missions.map((mission) => mission.slug));
}

export function getTrailProgress(
  trail: TrailSummary,
  completedMissions: string[],
): { done: number; total: number; pct: number } {
  const slugs = getTrailMissionSlugs(trail);
  const done = slugs.filter((s) => completedMissions.includes(s)).length;
  const total = slugs.length;
  return { done, total, pct: total > 0 ? Math.round((done / total) * 100) : 0 };
}

export function isTrailCompleted(
  trail: TrailSummary,
  completedMissions: string[],
): boolean {
  const slugs = getTrailMissionSlugs(trail);
  if (slugs.length === 0) return false;
  return slugs.every((s) => completedMissions.includes(s));
}

export function isTrailUnlocked(
  trail: TrailSummary,
  allTrails: TrailSummary[],
  completedMissions: string[],
): boolean {
  if (!trail.unlockAfter) return true;
  const prereq = allTrails.find((t) => t.slug === trail.unlockAfter);
  if (!prereq) return true;
  return isTrailCompleted(prereq, completedMissions);
}

export function getCurrentMission(
  trail: TrailSummary,
  completedMissions: string[],
  allMissionSlugs: string[],
): MissionSummary | null {
  for (const mod of trail.modules) {
    for (const mission of mod.missions) {
      if (!completedMissions.includes(mission.slug)) {
        const index = allMissionSlugs.indexOf(mission.slug);
        if (index <= 0 || completedMissions.includes(allMissionSlugs[index - 1])) {
          return mission;
        }
      }
    }
  }
  return null;
}

export function findActiveTrail(
  trails: TrailSummary[],
  completedMissions: string[],
): TrailSummary | null {
  const sorted = [...trails].sort((a, b) => a.order - b.order);
  for (const trail of sorted) {
    if (trail.comingSoon || getTrailMissionSlugs(trail).length === 0) continue;
    if (!isTrailUnlocked(trail, trails, completedMissions)) continue;
    if (!isTrailCompleted(trail, completedMissions)) return trail;
  }
  return sorted.find((t) => getTrailMissionSlugs(t).length > 0) ?? null;
}
