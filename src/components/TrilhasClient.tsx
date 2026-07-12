"use client";

import { TrailCard } from "./TrailCard";
import type { TrailSummary } from "@/lib/trails";
import { useProgress } from "@/lib/store";
import { isTrailUnlocked } from "@/lib/trails";

export function TrilhasClient({ trails }: { trails: TrailSummary[] }) {
  const { completedMissions } = useProgress();
  const sorted = [...trails].sort((a, b) => a.order - b.order);

  const unlocked = sorted.filter((t) =>
    isTrailUnlocked(t, trails, completedMissions),
  );
  const locked = sorted.filter(
    (t) => !isTrailUnlocked(t, trails, completedMissions),
  );

  return (
    <div className="space-y-8 px-4 py-6">
      <section>
        <h2 className="mb-1 text-xl font-extrabold text-text">
          Suas trilhas
        </h2>
        <p className="mb-4 text-sm text-text-muted">
          {unlocked.length} liberada{unlocked.length !== 1 ? "s" : ""} ·{" "}
          {locked.length} bloqueada{locked.length !== 1 ? "s" : ""}
        </p>
        <div className="space-y-4">
          {unlocked.map((trail) => (
            <TrailCard key={trail.slug} trail={trail} allTrails={trails} />
          ))}
        </div>
      </section>

      {locked.length > 0 && (
        <section>
          <h2 className="mb-4 text-xl font-extrabold text-text-muted">
            🔒 Bloqueadas
          </h2>
          <div className="space-y-4">
            {locked.map((trail) => (
              <TrailCard key={trail.slug} trail={trail} allTrails={trails} />
            ))}
          </div>
        </section>
      )}
    </div>
  );
}
