"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { AnimatePresence, motion } from "framer-motion";
import type { QuestionOption } from "@/lib/prisma";

type Question = {
  id: string;
  question: string;
  options: QuestionOption[];
  correctOptionId: string;
  feedbackCorrect: string;
  feedbackWrong: Record<string, string>;
  verseRef: string | null;
};

type MissionData = {
  slug: string;
  title: string;
  intro: string;
  type: string;
  xpReward: number;
  questions: Question[];
};

export function LessonClient({
  mission,
  trailSlug,
}: {
  mission: MissionData;
  trailSlug: string;
}) {
  const router = useRouter();
  const [phase, setPhase] = useState<"intro" | "quiz" | "feedback">("intro");
  const [questionIndex, setQuestionIndex] = useState(0);
  const [selected, setSelected] = useState<string | null>(null);
  const [isCorrect, setIsCorrect] = useState<boolean | null>(null);
  const [correctCount, setCorrectCount] = useState(0);

  const question = mission.questions[questionIndex];
  const progress = ((questionIndex + (phase === "feedback" ? 1 : 0)) / mission.questions.length) * 100;

  function handleSelect(optionId: string) {
    if (selected || phase !== "quiz") return;
    const correct = optionId === question.correctOptionId;
    setSelected(optionId);
    setIsCorrect(correct);
    if (correct) setCorrectCount((c) => c + 1);
    setPhase("feedback");
  }

  function handleContinue() {
    if (questionIndex < mission.questions.length - 1) {
      setQuestionIndex((i) => i + 1);
      setSelected(null);
      setIsCorrect(null);
      setPhase("quiz");
      return;
    }

    const params = new URLSearchParams({
      xp: String(mission.xpReward),
      correct: String(correctCount),
      total: String(mission.questions.length),
      trail: trailSlug,
    });
    router.push(`/missao/${mission.slug}/completo?${params}`);
  }

  return (
    <div className="mx-auto flex min-h-[calc(100dvh-64px)] max-w-lg flex-col px-4 py-6">
      <div className="mb-6 h-3 overflow-hidden rounded-full bg-primary/15">
        <motion.div
          className="h-full rounded-full bg-primary"
          animate={{ width: `${progress}%` }}
          transition={{ duration: 0.3 }}
        />
      </div>

      <AnimatePresence mode="wait">
        {phase === "intro" && (
          <motion.div
            key="intro"
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -12 }}
            className="flex flex-1 flex-col"
          >
            <div className="mb-4 text-4xl">{mission.type === "boss" ? "🏆" : "📖"}</div>
            <h1 className="mb-3 text-2xl font-extrabold text-text">{mission.title}</h1>
            <p className="mb-8 flex-1 leading-relaxed text-text-muted">{mission.intro}</p>
            <button
              type="button"
              onClick={() => setPhase("quiz")}
              className="btn-3d w-full rounded-2xl bg-primary py-4 text-lg font-extrabold text-white"
            >
              COMEÇAR
            </button>
          </motion.div>
        )}

        {(phase === "quiz" || phase === "feedback") && question && (
          <motion.div
            key={`q-${questionIndex}`}
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="flex flex-1 flex-col"
          >
            {question.verseRef && (
              <p className="mb-2 text-sm font-semibold text-primary">{question.verseRef}</p>
            )}
            <h2 className="mb-6 text-xl font-bold leading-snug text-text">{question.question}</h2>

            <div className="flex flex-1 flex-col gap-3">
              {question.options.map((opt) => {
                let style =
                  "border-2 border-primary/15 bg-card text-text hover:border-primary/40";
                if (phase === "feedback" && selected === opt.id) {
                  style = isCorrect
                    ? "border-success bg-success/15 text-success-dark"
                    : "border-error bg-error/10 text-error";
                } else if (phase === "feedback" && opt.id === question.correctOptionId) {
                  style = "border-success bg-success/15 text-success-dark";
                }

                return (
                  <button
                    key={opt.id}
                    type="button"
                    disabled={phase === "feedback"}
                    onClick={() => handleSelect(opt.id)}
                    className={`rounded-2xl px-4 py-4 text-left text-base font-semibold transition ${style}`}
                  >
                    {opt.text}
                  </button>
                );
              })}
            </div>

            {phase === "feedback" && (
              <motion.div
                initial={{ opacity: 0, y: 16 }}
                animate={{ opacity: 1, y: 0 }}
                className={`mt-6 rounded-2xl p-4 ${
                  isCorrect ? "bg-success/15 text-green-900" : "bg-error/10 text-red-900"
                }`}
              >
                <p className="mb-1 font-extrabold">{isCorrect ? "Correto! 🎉" : "Quase!"}</p>
                <p className="text-sm leading-relaxed">
                  {isCorrect
                    ? question.feedbackCorrect
                    : selected
                      ? question.feedbackWrong[selected] ??
                        "Revise o versículo e tente lembrar na próxima."
                      : ""}
                </p>
                <button
                  type="button"
                  onClick={handleContinue}
                  className={`btn-3d mt-4 w-full rounded-2xl py-3 font-extrabold text-white ${
                    isCorrect ? "btn-success bg-success" : "bg-primary"
                  }`}
                >
                  {questionIndex < mission.questions.length - 1 ? "CONTINUAR" : "FINALIZAR"}
                </button>
              </motion.div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
