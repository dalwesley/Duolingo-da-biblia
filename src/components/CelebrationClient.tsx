"use client";

import { useEffect } from "react";
import Link from "next/link";
import { motion } from "framer-motion";
import { useProgress } from "@/lib/store";

export function CelebrationClient({
  missionSlug,
  xp,
  correct,
  total,
  trailSlug,
}: {
  missionSlug: string;
  xp: number;
  correct: number;
  total: number;
  trailSlug: string;
}) {
  const { completeMission, streak } = useProgress();

  useEffect(() => {
    completeMission(missionSlug, xp);
  }, [missionSlug, xp, completeMission]);

  const pct = total > 0 ? Math.round((correct / total) * 100) : 100;

  return (
    <div className="mx-auto flex min-h-[calc(100dvh-64px)] max-w-lg flex-col items-center justify-center px-4 py-8 text-center">
      <motion.div
        initial={{ scale: 0.5, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ type: "spring", bounce: 0.5 }}
        className="mb-6 text-7xl"
      >
        🎉
      </motion.div>

      <motion.h1
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.1 }}
        className="mb-2 text-3xl font-extrabold text-text"
      >
        Missão completa!
      </motion.h1>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.2 }}
        className="mb-8 text-text-muted"
      >
        Você dominou mais um passo da jornada.
      </motion.p>

      <motion.div
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.3 }}
        className="mb-8 grid w-full grid-cols-2 gap-3"
      >
        <div className="rounded-2xl bg-warning/20 p-4">
          <p className="text-2xl font-extrabold text-amber-700">+{xp}</p>
          <p className="text-sm text-text-muted">XP ganhos</p>
        </div>
        <div className="rounded-2xl bg-error/15 p-4">
          <p className="text-2xl font-extrabold text-orange-700">🔥 {streak}</p>
          <p className="text-sm text-text-muted">Dias de sequência</p>
        </div>
      </motion.div>

      <div className="flex w-full flex-col gap-3">
        <Link
          href={`/trilha/${trailSlug}`}
          className="btn-3d btn-success block w-full rounded-2xl bg-success py-4 text-lg font-extrabold text-white"
        >
          CONTINUAR TRILHA
        </Link>
        <Link
          href="/home"
          className="block w-full rounded-2xl border-2 border-primary/20 py-3 font-bold text-primary"
        >
          INÍCIO
        </Link>
      </div>

      <p className="mt-6 text-xs text-text-muted">
        {pct}% de acertos nesta sessão ({correct}/{total})
      </p>
    </div>
  );
}
