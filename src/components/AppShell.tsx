import { BottomNav } from "./BottomNav";
import { TopBar } from "./TopBar";

export function AppShell({
  children,
  showNav = true,
  backHref,
  title,
  subtitle,
}: {
  children: React.ReactNode;
  showNav?: boolean;
  backHref?: string;
  title?: string;
  subtitle?: string;
}) {
  return (
    <div className={`min-h-dvh bg-surface ${showNav ? "app-shell" : ""}`}>
      <TopBar backHref={backHref} title={title} subtitle={subtitle} />
      <main className="mx-auto max-w-lg">{children}</main>
      {showNav && <BottomNav />}
    </div>
  );
}
