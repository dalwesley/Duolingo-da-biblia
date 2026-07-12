import { prisma } from "@/lib/prisma";
import type { TrailSummary } from "@/lib/trails";

export async function getTrails(): Promise<TrailSummary[]> {
  const trails = await prisma.trail.findMany({
    include: {
      modules: {
        include: {
          missions: {
            select: {
              slug: true,
              title: true,
              type: true,
              xpReward: true,
              order: true,
            },
            orderBy: { order: "asc" },
          },
        },
        orderBy: { order: "asc" },
      },
    },
    orderBy: { order: "asc" },
  });

  return trails.map((trail) => ({
    slug: trail.slug,
    title: trail.title,
    description: trail.description,
    icon: trail.icon,
    order: trail.order,
    unlockAfter: trail.unlockAfter,
    comingSoon: trail.comingSoon,
    color: trail.color,
    modules: trail.modules.map((mod) => ({
      title: mod.title,
      icon: mod.icon,
      missions: mod.missions,
    })),
  }));
}

export async function getTrailBySlug(slug: string) {
  const trails = await getTrails();
  return trails.find((t) => t.slug === slug) ?? null;
}
