"use client";

import type { TrailSummary } from "@/lib/trails";
import { getTrailProgress } from "@/lib/trails";
import { useProgress } from "@/lib/store";

export function TrailPageHeader({
  trail,
  allMissionSlugs,
}: {
  trail: TrailSummary;
  allMissionSlugs: string[];
}) {
  const { completedMissions } = useProgress();
  const progress = getTrailProgress(trail, completedMissions);

  return (
    <div className="py-6 text-center">
      <div
        className="mx-auto mb-4 flex h-20 w-20 items-center justify-center rounded-full text-4xl"
        style={{ backgroundColor: `${trail.color}20` }}
      >
        {trail.icon}
      </div>
      <h1 className="text-2xl font-extrabold text-text">{trail.title}</h1>
      <p className="mt-1 text-sm text-text-muted">{trail.description}</p>

      <div className="mx-auto mt-4 max-w-xs">
        <div className="mb-1 flex justify-between text-xs font-extrabold">
          <span className="text-text-muted">Progresso</span>
          <span style={{ color: trail.color }}>
            {progress.done}/{progress.total}
          </span>
        </div>
        <div className="h-3 overflow-hidden rounded-full bg-black/5">
          <div
            className="h-full rounded-full transition-all"
            style={{
              width: `${progress.pct}%`,
              backgroundColor: trail.color,
            }}
          />
        </div>
      </div>
    </div>
  );
}
