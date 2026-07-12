"use client";

import Link from "next/link";
import { motion } from "framer-motion";
import { useProgress } from "@/lib/store";

type Mission = {
  slug: string;
  title: string;
  type: string;
  xpReward: number;
  order: number;
};

type Module = {
  title: string;
  icon: string;
  missions: Mission[];
};

function MissionNode({
  mission,
  completed,
  unlocked,
  isCurrent,
  isBoss,
  offset,
}: {
  mission: Mission;
  completed: boolean;
  unlocked: boolean;
  isCurrent: boolean;
  isBoss: boolean;
  offset: "left" | "center" | "right";
}) {
  const align =
    offset === "left"
      ? "self-start ml-8"
      : offset === "right"
        ? "self-end mr-8"
        : "self-center";

  const nodeSize = isBoss ? "h-20 w-20" : "h-16 w-16";
  const icon = completed ? "✓" : isBoss ? "🏆" : unlocked ? "⭐" : "🔒";

  const baseClasses = `relative flex ${nodeSize} items-center justify-center rounded-full text-2xl font-extrabold transition`;

  const colorClasses = completed
    ? "bg-success text-white trail-node-shadow"
    : isCurrent
      ? "bg-primary text-white trail-node-current"
      : unlocked
        ? "bg-card border-4 border-primary/30 text-primary trail-node-shadow"
        : "bg-[#e5e5e5] text-text-muted trail-node-locked";

  const content = (
    <motion.div
      whileTap={unlocked ? { scale: 0.92 } : undefined}
      animate={isCurrent ? { scale: [1, 1.06, 1] } : undefined}
      transition={isCurrent ? { repeat: Infinity, duration: 2 } : undefined}
      className={`${baseClasses} ${colorClasses} ${align}`}
    >
      {icon}
      {isCurrent && (
        <span className="absolute -top-2 left-1/2 -translate-x-1/2 whitespace-nowrap rounded-full bg-success px-2 py-0.5 text-[10px] font-extrabold uppercase text-white shadow">
          Começar
        </span>
      )}
    </motion.div>
  );

  return (
    <div className={`flex w-full flex-col items-center ${align}`}>
      {unlocked ? (
        <Link href={`/missao/${mission.slug}`} title={mission.title}>
          {content}
        </Link>
      ) : (
        content
      )}
      <p
        className={`mt-2 max-w-[140px] text-center text-xs font-bold leading-tight ${
          unlocked ? "text-text" : "text-text-muted"
        }`}
      >
        {mission.title}
      </p>
      {unlocked && (
        <p className="text-[10px] font-bold text-text-muted">
          +{mission.xpReward} XP
        </p>
      )}
    </div>
  );
}

function Connector({ active }: { active: boolean }) {
  return (
    <div
      className={`my-1 h-10 w-1 rounded-full ${
        active ? "bg-success" : "bg-black/10"
      }`}
    />
  );
}

export function TrailMap({
  modules,
  allMissionSlugs,
  trailColor,
}: {
  trailSlug: string;
  modules: Module[];
  allMissionSlugs: string[];
  trailColor?: string;
}) {
  const { isMissionCompleted, isMissionUnlocked } = useProgress();

  let globalIndex = 0;

  return (
    <div className="space-y-10 py-4">
      {modules.map((mod, mi) => (
        <section key={mod.title}>
          <div
            className="mb-6 flex items-center gap-3 rounded-2xl border-2 bg-card px-4 py-3"
            style={{ borderColor: trailColor ? `${trailColor}30` : undefined }}
          >
            <span className="text-2xl">{mod.icon}</span>
            <div>
              <p className="text-xs font-extrabold uppercase tracking-wide text-text-muted">
                Módulo {mi + 1}
              </p>
              <h2 className="text-lg font-extrabold text-text">{mod.title}</h2>
            </div>
          </div>

          <div className="flex flex-col items-center gap-1">
            {mod.missions.map((mission, index) => {
              const completed = isMissionCompleted(mission.slug);
              const unlocked = isMissionUnlocked(mission.slug, allMissionSlugs);
              const isCurrent = unlocked && !completed;
              const isBoss = mission.type === "boss";
              const offset =
                globalIndex % 3 === 0
                  ? "center"
                  : globalIndex % 3 === 1
                    ? "right"
                    : "left";
              globalIndex++;

              const prevCompleted =
                index > 0
                  ? isMissionCompleted(mod.missions[index - 1].slug)
                  : true;

              return (
                <div key={mission.slug} className="flex w-full flex-col items-center">
                  {index > 0 && <Connector active={prevCompleted || completed} />}
                  <MissionNode
                    mission={mission}
                    completed={completed}
                    unlocked={unlocked}
                    isCurrent={isCurrent}
                    isBoss={isBoss}
                    offset={offset as "left" | "center" | "right"}
                  />
                </div>
              );
            })}
          </div>

          {mi < modules.length - 1 && (
            <div className="mx-auto mt-8 flex items-center gap-2">
              <div className="h-px flex-1 bg-black/10" />
              <span className="text-lg">⬇️</span>
              <div className="h-px flex-1 bg-black/10" />
            </div>
          )}
        </section>
      ))}
    </div>
  );
}
