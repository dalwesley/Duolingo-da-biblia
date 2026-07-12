"use client";

import { useEffect } from "react";
import { useRouter } from "next/navigation";
import { motion } from "framer-motion";
import { useProgress } from "@/lib/store";

export function SplashClient() {
  const router = useRouter();
  const { hasSeenSplash, setHasSeenSplash } = useProgress();

  useEffect(() => {
    if (hasSeenSplash) {
      router.replace("/home");
      return;
    }

    const timer = setTimeout(() => {
      setHasSeenSplash(true);
      router.replace("/home");
    }, 2400);

    return () => clearTimeout(timer);
  }, [hasSeenSplash, router, setHasSeenSplash]);

  return (
    <div className="splash-gradient flex min-h-dvh flex-col items-center justify-center px-6 text-white">
      <motion.div
        initial={{ scale: 0.6, opacity: 0 }}
        animate={{ scale: 1, opacity: 1 }}
        transition={{ type: "spring", bounce: 0.4, duration: 0.8 }}
        className="splash-logo mb-6 text-8xl"
      >
        📖
      </motion.div>

      <motion.h1
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.3 }}
        className="mb-2 text-4xl font-extrabold tracking-tight"
      >
        Trilha
      </motion.h1>

      <motion.p
        initial={{ y: 20, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ delay: 0.45 }}
        className="mb-16 text-center text-lg font-semibold text-white/85"
      >
        Aprenda a Bíblia, uma missão por vez.
      </motion.p>

      <div className="absolute bottom-16 left-8 right-8">
        <div className="h-3 overflow-hidden rounded-full bg-white/20">
          <div className="splash-progress h-full rounded-full bg-white" />
        </div>
        <p className="mt-3 text-center text-xs font-bold text-white/70">
          Carregando sua jornada...
        </p>
      </div>
    </div>
  );
}
