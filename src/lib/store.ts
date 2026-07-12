"use client";

import { create } from "zustand";
import { persist } from "zustand/middleware";

export type AppSettings = {
  sound: boolean;
  notifications: boolean;
  dailyGoal: 1 | 2 | 3;
};

type ProgressState = {
  xp: number;
  streak: number;
  lastPlayedDate: string | null;
  completedMissions: string[];
  missionsToday: number;
  hasSeenSplash: boolean;
  userName: string;
  settings: AppSettings;

  recordSession: () => void;
  completeMission: (missionSlug: string, xp: number) => void;
  isMissionCompleted: (missionSlug: string) => boolean;
  isMissionUnlocked: (missionSlug: string, allSlugs: string[]) => boolean;
  setHasSeenSplash: (value: boolean) => void;
  setUserName: (name: string) => void;
  updateSettings: (partial: Partial<AppSettings>) => void;
  resetProgress: () => void;
};

function todayKey() {
  return new Date().toISOString().slice(0, 10);
}

function yesterdayKey() {
  const d = new Date();
  d.setDate(d.getDate() - 1);
  return d.toISOString().slice(0, 10);
}

const defaultSettings: AppSettings = {
  sound: true,
  notifications: true,
  dailyGoal: 1,
};

export const useProgress = create<ProgressState>()(
  persist(
    (set, get) => ({
      xp: 0,
      streak: 0,
      lastPlayedDate: null,
      completedMissions: [],
      missionsToday: 0,
      hasSeenSplash: false,
      userName: "Estudante",
      settings: defaultSettings,

      recordSession: () => {
        const today = todayKey();
        const { lastPlayedDate, streak } = get();
        if (lastPlayedDate === today) return;

        let newStreak = 1;
        if (lastPlayedDate === yesterdayKey()) {
          newStreak = streak + 1;
        }

        set({ lastPlayedDate: today, streak: newStreak, missionsToday: 0 });
      },

      completeMission: (missionSlug, xp) => {
        const { completedMissions, lastPlayedDate } = get();
        const today = todayKey();
        const alreadyToday = lastPlayedDate === today;

        if (completedMissions.includes(missionSlug)) return;

        set({
          completedMissions: [...completedMissions, missionSlug],
          xp: get().xp + xp,
          missionsToday: alreadyToday ? get().missionsToday + 1 : 1,
        });
        get().recordSession();
      },

      isMissionCompleted: (missionSlug) =>
        get().completedMissions.includes(missionSlug),

      isMissionUnlocked: (missionSlug, allSlugs) => {
        const index = allSlugs.indexOf(missionSlug);
        if (index <= 0) return true;
        const previous = allSlugs[index - 1];
        return get().completedMissions.includes(previous);
      },

      setHasSeenSplash: (value) => set({ hasSeenSplash: value }),
      setUserName: (name) => set({ userName: name.trim() || "Estudante" }),
      updateSettings: (partial) =>
        set({ settings: { ...get().settings, ...partial } }),
      resetProgress: () =>
        set({
          xp: 0,
          streak: 0,
          lastPlayedDate: null,
          completedMissions: [],
          missionsToday: 0,
        }),
    }),
    { name: "trilha-progress" },
  ),
);
