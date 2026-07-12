"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import type { MissionSummary } from "@/lib/trails";

export function ContinueCard({
  mission,
  trailSlug,
  trailTitle,
  trailIcon,
  trailColor,
}: {
  mission: MissionSummary | null;
  trailSlug: string;
  trailTitle: string;
  trailIcon: string;
  trailColor: string;
}) {
  if (!mission) {
    return (
      <div className="rounded-2xl border-2 border-success/30 bg-success/10 p-6 text-center">
        <span className="text-5xl">🏆</span>
        <h3 className="mt-3 text-xl font-extrabold text-text">
          Trilha completa!
        </h3>
        <p className="mt-1 text-sm text-text-muted">
          Explore outras trilhas ou aguarde novos conteúdos.
        </p>
        <Link
          href="/trilhas"
          className="btn-success mt-4 inline-block rounded-2xl bg-success px-8 py-3 font-extrabold text-white"
        >
          VER TRILHAS
        </Link>
      </div>
    );
  }

  return (
    <Link href={`/missao/${mission.slug}`}>
      <motion.div
        whileTap={{ scale: 0.98 }}
        className="btn-success overflow-hidden rounded-2xl bg-success p-5 text-white"
      >
        <div className="flex items-center gap-4">
          <div
            className="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-white/20 text-2xl"
          >
            {mission.type === "boss" ? "🏆" : "⭐"}
          </div>
          <div className="min-w-0 flex-1">
            <p className="text-xs font-extrabold uppercase tracking-wider text-white/80">
              Continuar · {trailIcon} {trailTitle}
            </p>
            <p className="truncate text-lg font-extrabold">{mission.title}</p>
            <p className="text-xs font-bold text-white/80">
              +{mission.xpReward} XP
            </p>
          </div>
          <span className="text-2xl font-extrabold">→</span>
        </div>
      </motion.div>
    </Link>
  );
}
