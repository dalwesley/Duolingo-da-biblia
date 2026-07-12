"use client";

import { motion } from "framer-motion";

const greetings = [
  { hour: 5, msg: "Bom dia! Pronto para aprender?" },
  { hour: 12, msg: "Boa tarde! Vamos continuar?" },
  { hour: 18, msg: "Boa noite! Mais uma missão?" },
  { hour: 24, msg: "Ainda estudando? Que dedicação!" },
];

function getGreeting() {
  const hour = new Date().getHours();
  return greetings.find((g) => hour < g.hour)?.msg ?? greetings[0].msg;
}

export function Mascot({
  message,
  size = "md",
}: {
  message?: string;
  size?: "sm" | "md" | "lg";
}) {
  const sizes = { sm: "text-4xl", md: "text-6xl", lg: "text-7xl" };

  return (
    <div className="flex items-end gap-3">
      <motion.div
        animate={{ y: [0, -6, 0] }}
        transition={{ repeat: Infinity, duration: 2.5, ease: "easeInOut" }}
        className={sizes[size]}
      >
        🕊️
      </motion.div>
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="relative max-w-[200px] rounded-2xl rounded-bl-sm border-2 border-black/10 bg-card px-4 py-3 shadow-sm"
      >
        <p className="text-sm font-bold leading-snug text-text">
          {message ?? getGreeting()}
        </p>
        <div className="absolute -left-2 bottom-3 h-3 w-3 rotate-45 border-b-2 border-l-2 border-black/10 bg-card" />
      </motion.div>
    </div>
  );
}
