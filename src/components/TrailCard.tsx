"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import type { MissionSummary, TrailSummary } from "@/lib/trails";
import {
  getTrailMissionSlugs,
  getTrailProgress,
  isTrailCompleted,
  isTrailUnlocked,
} from "@/lib/trails";
import { useProgress } from "@/lib/store";

export function TrailCard({
  trail,
  allTrails,
}: {
  trail: TrailSummary;
  allTrails: TrailSummary[];
}) {
  const { completedMissions } = useProgress();
  const unlocked = isTrailUnlocked(trail, allTrails, completedMissions);
  const completed = isTrailCompleted(trail, completedMissions);
  const progress = getTrailProgress(trail, completedMissions);
  const hasContent = getTrailMissionSlugs(trail).length > 0;

  const card = (
    <motion.div
      whileTap={unlocked && hasContent ? { scale: 0.98 } : undefined}
      className={`relative overflow-hidden rounded-2xl border-2 p-5 transition ${
        unlocked && hasContent
          ? "border-black/10 bg-card shadow-sm hover:shadow-md"
          : "border-dashed border-black/15 bg-card/60"
      }`}
      style={
        unlocked && hasContent
          ? { borderColor: `${trail.color}40` }
          : undefined
      }
    >
      {!unlocked && (
        <div className="absolute inset-0 z-10 flex items-center justify-center bg-black/5 backdrop-blur-[1px]">
          <div className="flex flex-col items-center gap-1 rounded-2xl bg-card/90 px-6 py-4 shadow-lg">
            <span className="text-3xl">🔒</span>
            <p className="text-xs font-extrabold text-text-muted">
              {trail.unlockAfter
                ? `Complete ${allTrails.find((t) => t.slug === trail.unlockAfter)?.title ?? trail.unlockAfter}`
                : "Bloqueada"}
            </p>
          </div>
        </div>
      )}

      {trail.comingSoon && unlocked && (
        <div className="absolute right-3 top-3 rounded-full bg-warning px-2.5 py-1 text-[10px] font-extrabold uppercase text-amber-900">
          Em breve
        </div>
      )}

      {completed && (
        <div className="absolute right-3 top-3 rounded-full bg-success px-2.5 py-1 text-[10px] font-extrabold uppercase text-white">
          Completa
        </div>
      )}

      <div className="flex items-start gap-4">
        <div
          className="flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl text-3xl"
          style={{ backgroundColor: `${trail.color}20` }}
        >
          {trail.icon}
        </div>
        <div className="min-w-0 flex-1">
          <h3 className="text-lg font-extrabold text-text">{trail.title}</h3>
          <p className="mt-1 line-clamp-2 text-sm text-text-muted">
            {trail.description}
          </p>

          {hasContent && unlocked && (
            <div className="mt-3">
              <div className="mb-1 flex justify-between text-xs font-bold">
                <span className="text-text-muted">Progresso</span>
                <span style={{ color: trail.color }}>{progress.pct}%</span>
              </div>
              <div className="h-2.5 overflow-hidden rounded-full bg-black/5">
                <div
                  className="h-full rounded-full transition-all"
                  style={{
                    width: `${progress.pct}%`,
                    backgroundColor: trail.color,
                  }}
                />
              </div>
              <p className="mt-1.5 text-xs font-bold text-text-muted">
                {progress.done}/{progress.total} missões
              </p>
            </div>
          )}

          {!hasContent && unlocked && (
            <p className="mt-3 text-xs font-bold text-warning">
              Conteúdo em desenvolvimento
            </p>
          )}
        </div>
      </div>
    </motion.div>
  );

  if (unlocked && hasContent && !trail.comingSoon) {
    return <Link href={`/trilha/${trail.slug}`}>{card}</Link>;
  }

  return card;
}
