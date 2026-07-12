import { AppShell } from "@/components/AppShell";
import { TrilhasClient } from "@/components/TrilhasClient";
import { getTrails } from "@/lib/db-trails";

export const dynamic = "force-dynamic";

export default async function TrilhasPage() {
  const trails = await getTrails();

  return (
    <AppShell title="Trilhas" subtitle="Escolha sua jornada">
      <TrilhasClient trails={trails} />
    </AppShell>
  );
}
