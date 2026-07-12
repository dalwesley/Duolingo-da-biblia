import { AppShell } from "@/components/AppShell";
import { SettingsClient } from "@/components/SettingsClient";

export default function ConfiguracoesPage() {
  return (
    <AppShell title="Configurações" subtitle="Personalize sua experiência">
      <SettingsClient />
    </AppShell>
  );
}
