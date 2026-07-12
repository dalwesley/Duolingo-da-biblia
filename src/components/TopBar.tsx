"use client";

import Link from "next/link";
import { useProgress } from "@/lib/store";

export function TopBar({
  backHref,
  title,
  subtitle,
}: {
  backHref?: string;
  title?: string;
  subtitle?: string;
}) {
  const { xp, streak } = useProgress();

  return (
    <header className="sticky top-0 z-20 border-b-2 border-black/5 bg-card">
      <div className="mx-auto flex max-w-lg items-center justify-between px-4 py-3">
        <div className="flex min-w-0 items-center gap-2">
          {backHref ? (
            <Link
              href={backHref}
              className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border-2 border-black/10 bg-surface text-lg font-bold text-text transition hover:bg-primary/10"
            >
              ←
            </Link>
          ) : (
            <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary text-xl">
              📖
            </div>
          )}
          <div className="min-w-0">
            <p className="truncate text-sm font-extrabold text-text">
              {title ?? "Trilha"}
            </p>
            <p className="truncate text-xs text-text-muted">
              {subtitle ?? "Bíblia gamificada"}
            </p>
          </div>
        </div>

        <div className="flex shrink-0 items-center gap-2">
          <div className="flex items-center gap-1 rounded-xl border-2 border-warning/40 bg-warning/15 px-2.5 py-1.5">
            <span className="text-sm">⭐</span>
            <span className="text-sm font-extrabold text-amber-800">{xp}</span>
          </div>
          <div className="flex items-center gap-1 rounded-xl border-2 border-error/30 bg-error/10 px-2.5 py-1.5">
            <span className="text-sm">🔥</span>
            <span className="text-sm font-extrabold text-red-600">{streak}</span>
          </div>
        </div>
      </div>
    </header>
  );
}
