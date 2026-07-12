"use client";

import Link from "next/link";
import { Mascot } from "./Mascot";
import { DailyGoalBar } from "./DailyGoalBar";
import { ContinueCard } from "./ContinueCard";
import type { TrailSummary } from "@/lib/trails";
import {
  findActiveTrail,
  getCurrentMission,
  getTrailMissionSlugs,
  getTrailProgress,
} from "@/lib/trails";
import { useProgress } from "@/lib/store";

export function HomeClient({ trails }: { trails: TrailSummary[] }) {
  const { userName, completedMissions } = useProgress();
  const activeTrail = findActiveTrail(trails, completedMissions);

  const currentMission = activeTrail
    ? getCurrentMission(
        activeTrail,
        completedMissions,
        getTrailMissionSlugs(activeTrail),
      )
    : null;

  const progress = activeTrail
    ? getTrailProgress(activeTrail, completedMissions)
    : null;

  const mascotMsg = currentMission
    ? `E aí, ${userName}! Pronto para "${currentMission.title}"?`
    : `Parabéns, ${userName}! Você está arrasando!`;

  return (
    <div className="space-y-6 px-4 py-6">
      <Mascot message={mascotMsg} />

      <ContinueCard
        mission={currentMission}
        trailSlug={activeTrail?.slug ?? ""}
        trailTitle={activeTrail?.title ?? ""}
        trailIcon={activeTrail?.icon ?? "📖"}
        trailColor={activeTrail?.color ?? "#6C5CE7"}
      />

      <DailyGoalBar />

      {activeTrail && progress && (
        <Link href={`/trilha/${activeTrail.slug}`}>
          <div
            className="rounded-2xl border-2 bg-card p-4 transition hover:shadow-md"
            style={{ borderColor: `${activeTrail.color}30` }}
          >
            <div className="flex items-center gap-3">
              <span className="text-3xl">{activeTrail.icon}</span>
              <div className="flex-1">
                <p className="text-sm font-extrabold text-text">
                  {activeTrail.title}
                </p>
                <p className="text-xs text-text-muted">
                  {progress.done} de {progress.total} missões
                </p>
                <div className="mt-2 h-2 overflow-hidden rounded-full bg-black/5">
                  <div
                    className="h-full rounded-full"
                    style={{
                      width: `${progress.pct}%`,
                      backgroundColor: activeTrail.color,
                    }}
                  />
                </div>
              </div>
              <span className="font-extrabold" style={{ color: activeTrail.color }}>
                →
              </span>
            </div>
          </div>
        </Link>
      )}

      <div className="grid grid-cols-2 gap-3">
        <div className="rounded-2xl border-2 border-black/10 bg-card p-4 text-center">
          <p className="text-2xl">📚</p>
          <p className="mt-1 text-lg font-extrabold text-text">
            {trails.filter((t) => getTrailMissionSlugs(t).length > 0).length}
          </p>
          <p className="text-xs font-bold text-text-muted">Trilhas ativas</p>
        </div>
        <div className="rounded-2xl border-2 border-black/10 bg-card p-4 text-center">
          <p className="text-2xl">✅</p>
          <p className="mt-1 text-lg font-extrabold text-text">
            {completedMissions.length}
          </p>
          <p className="text-xs font-bold text-text-muted">Missões feitas</p>
        </div>
      </div>
    </div>
  );
}
