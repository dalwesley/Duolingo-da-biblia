"use client";

import { useProgress } from "@/lib/store";

export function DailyGoalBar() {
  const { missionsToday, settings } = useProgress();
  const goal = settings.dailyGoal;
  const pct = Math.min(100, Math.round((missionsToday / goal) * 100));
  const done = missionsToday >= goal;

  return (
    <div className="rounded-2xl border-2 border-black/10 bg-card p-4">
      <div className="mb-3 flex items-center justify-between">
        <div className="flex items-center gap-2">
          <span className="text-xl">🎯</span>
          <div>
            <p className="text-sm font-extrabold text-text">Meta diária</p>
            <p className="text-xs text-text-muted">
              {missionsToday}/{goal} missão{goal > 1 ? "ões" : ""}
            </p>
          </div>
        </div>
        {done ? (
          <span className="rounded-full bg-success/15 px-3 py-1 text-xs font-extrabold text-success">
            ✓ Feito!
          </span>
        ) : (
          <span className="text-xs font-bold text-text-muted">{pct}%</span>
        )}
      </div>
      <div className="h-3 overflow-hidden rounded-full bg-black/5">
        <div
          className="h-full rounded-full bg-success transition-all duration-500"
          style={{ width: `${pct}%` }}
        />
      </div>
    </div>
  );
}
