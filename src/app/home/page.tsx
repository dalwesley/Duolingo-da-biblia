import { AppShell } from "@/components/AppShell";
import { HomeClient } from "@/components/HomeClient";
import { getTrails } from "@/lib/db-trails";

export const dynamic = "force-dynamic";

export default async function HomePage() {
  const trails = await getTrails();

  return (
    <AppShell title="Início" subtitle="Sua jornada bíblica">
      <HomeClient trails={trails} />
    </AppShell>
  );
}
