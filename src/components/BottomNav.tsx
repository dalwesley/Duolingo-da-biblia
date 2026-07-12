"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

const tabs = [
  { href: "/home", label: "Início", icon: "🏠", activeIcon: "🏠" },
  { href: "/trilhas", label: "Trilhas", icon: "📚", activeIcon: "📖" },
  { href: "/configuracoes", label: "Config", icon: "⚙️", activeIcon: "⚙️" },
] as const;

export function BottomNav() {
  const pathname = usePathname();

  return (
    <nav className="bottom-nav fixed bottom-0 left-0 right-0 z-30 border-t-2 border-black/5 bg-card">
      <div className="mx-auto flex h-[72px] max-w-lg items-stretch">
        {tabs.map((tab) => {
          const active =
            pathname === tab.href ||
            pathname.startsWith(`${tab.href}/`) ||
            (tab.href === "/trilhas" && pathname.startsWith("/trilha/"));
          return (
            <Link
              key={tab.href}
              href={tab.href}
              className={`flex flex-1 flex-col items-center justify-center gap-0.5 transition ${
                active
                  ? "text-primary"
                  : "text-text-muted hover:text-text"
              }`}
            >
              <span className={`text-2xl ${active ? "scale-110" : ""} transition`}>
                {active ? tab.activeIcon : tab.icon}
              </span>
              <span
                className={`text-[11px] font-extrabold uppercase tracking-wide ${
                  active ? "text-primary" : ""
                }`}
              >
                {tab.label}
              </span>
              {active && (
                <span className="absolute bottom-[calc(var(--safe-bottom)+6px)] h-1 w-8 rounded-full bg-primary" />
              )}
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
