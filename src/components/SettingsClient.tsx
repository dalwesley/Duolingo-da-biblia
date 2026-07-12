"use client";

import { useState } from "react";
import { useProgress } from "@/lib/store";

function Toggle({
  value,
  onChange,
  label,
  description,
}: {
  value: boolean;
  onChange: (v: boolean) => void;
  label: string;
  description?: string;
}) {
  return (
    <button
      type="button"
      onClick={() => onChange(!value)}
      className="flex w-full items-center justify-between rounded-2xl border-2 border-black/10 bg-card p-4 text-left transition hover:bg-surface"
    >
      <div>
        <p className="font-extrabold text-text">{label}</p>
        {description && (
          <p className="mt-0.5 text-xs text-text-muted">{description}</p>
        )}
      </div>
      <div
        className={`relative h-7 w-12 shrink-0 rounded-full transition ${
          value ? "bg-success" : "bg-black/15"
        }`}
      >
        <div
          className={`absolute top-0.5 h-6 w-6 rounded-full bg-white shadow transition ${
            value ? "left-[22px]" : "left-0.5"
          }`}
        />
      </div>
    </button>
  );
}

export function SettingsClient() {
  const {
    userName,
    setUserName,
    settings,
    updateSettings,
    resetProgress,
    xp,
    streak,
    completedMissions,
  } = useProgress();
  const [name, setName] = useState(userName);
  const [confirmReset, setConfirmReset] = useState(false);

  return (
    <div className="space-y-6 px-4 py-6">
      <section className="rounded-2xl border-2 border-primary/20 bg-gradient-to-br from-primary to-primary-dark p-6 text-white">
        <div className="flex items-center gap-4">
          <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-white/20 text-3xl">
            🕊️
          </div>
          <div>
            <p className="text-sm font-bold text-white/80">Seu perfil</p>
            <p className="text-xl font-extrabold">{userName}</p>
            <p className="text-xs text-white/70">
              ⭐ {xp} XP · 🔥 {streak} dias · ✅ {completedMissions.length}{" "}
              missões
            </p>
          </div>
        </div>
      </section>

      <section className="space-y-3">
        <h2 className="text-sm font-extrabold uppercase tracking-wide text-text-muted">
          Perfil
        </h2>
        <div className="rounded-2xl border-2 border-black/10 bg-card p-4">
          <label className="mb-2 block text-xs font-bold text-text-muted">
            Seu nome
          </label>
          <div className="flex gap-2">
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              maxLength={24}
              className="flex-1 rounded-xl border-2 border-black/10 bg-surface px-4 py-2.5 font-bold text-text outline-none focus:border-primary"
              placeholder="Como quer ser chamado?"
            />
            <button
              type="button"
              onClick={() => setUserName(name)}
              className="btn-3d rounded-xl bg-primary px-4 py-2.5 font-extrabold text-white"
            >
              Salvar
            </button>
          </div>
        </div>
      </section>

      <section className="space-y-3">
        <h2 className="text-sm font-extrabold uppercase tracking-wide text-text-muted">
          Meta diária
        </h2>
        <div className="grid grid-cols-3 gap-2">
          {([1, 2, 3] as const).map((goal) => (
            <button
              key={goal}
              type="button"
              onClick={() => updateSettings({ dailyGoal: goal })}
              className={`rounded-2xl border-2 py-4 font-extrabold transition ${
                settings.dailyGoal === goal
                  ? "border-success bg-success/15 text-success"
                  : "border-black/10 bg-card text-text-muted hover:border-primary/30"
              }`}
            >
              {goal}
              <span className="block text-xs font-bold">
                missão{goal > 1 ? "ões" : ""}
              </span>
            </button>
          ))}
        </div>
      </section>

      <section className="space-y-3">
        <h2 className="text-sm font-extrabold uppercase tracking-wide text-text-muted">
          Preferências
        </h2>
        <Toggle
          label="Sons"
          description="Efeitos sonoros nas lições"
          value={settings.sound}
          onChange={(sound) => updateSettings({ sound })}
        />
        <Toggle
          label="Notificações"
          description="Lembretes diários para estudar"
          value={settings.notifications}
          onChange={(notifications) => updateSettings({ notifications })}
        />
      </section>

      <section className="space-y-3">
        <h2 className="text-sm font-extrabold uppercase tracking-wide text-text-muted">
          Sobre
        </h2>
        <div className="rounded-2xl border-2 border-black/10 bg-card p-4">
          <p className="font-extrabold text-text">Trilha</p>
          <p className="mt-1 text-sm text-text-muted">
            Aprenda a Bíblia em missões curtas e gamificadas — estilo Duolingo.
          </p>
          <p className="mt-3 text-xs font-bold text-text-muted">Versão 0.1.0</p>
        </div>
      </section>

      <section className="space-y-3 pb-4">
        <h2 className="text-sm font-extrabold uppercase tracking-wide text-error">
          Zona de perigo
        </h2>
        {!confirmReset ? (
          <button
            type="button"
            onClick={() => setConfirmReset(true)}
            className="w-full rounded-2xl border-2 border-error/30 bg-error/5 py-4 font-extrabold text-error transition hover:bg-error/10"
          >
            Resetar progresso
          </button>
        ) : (
          <div className="space-y-2 rounded-2xl border-2 border-error/40 bg-error/5 p-4">
            <p className="text-sm font-bold text-error">
              Tem certeza? Todo XP, streak e missões serão apagados.
            </p>
            <div className="flex gap-2">
              <button
                type="button"
                onClick={() => setConfirmReset(false)}
                className="flex-1 rounded-xl border-2 border-black/10 py-3 font-extrabold text-text"
              >
                Cancelar
              </button>
              <button
                type="button"
                onClick={() => {
                  resetProgress();
                  setConfirmReset(false);
                }}
                className="flex-1 rounded-xl bg-error py-3 font-extrabold text-white"
              >
                Confirmar
              </button>
            </div>
          </div>
        )}
      </section>
    </div>
  );
}
