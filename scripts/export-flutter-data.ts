import { writeFileSync, mkdirSync } from "fs";
import { genesisTrail } from "../prisma/seed-data/genesis";
import { exodusTrail } from "../prisma/seed-data/exodus";
import { lockedTrails } from "../prisma/seed-data/locked-trails";

const trails = [
  {
    slug: genesisTrail.slug,
    title: genesisTrail.title,
    description: genesisTrail.description,
    icon: genesisTrail.icon,
    order: 1,
    unlockAfter: null,
    comingSoon: false,
    color: "#6C5CE7",
    modules: genesisTrail.modules,
  },
  {
    slug: exodusTrail.slug,
    title: exodusTrail.title,
    description: exodusTrail.description,
    icon: exodusTrail.icon,
    order: 2,
    unlockAfter: "genesis-1-11",
    comingSoon: false,
    color: exodusTrail.color,
    modules: exodusTrail.modules,
  },
  ...lockedTrails.map((t) => ({
    ...t,
    modules: [],
  })),
];

mkdirSync("trilha_app/assets/data", { recursive: true });
writeFileSync(
  "trilha_app/assets/data/trails.json",
  JSON.stringify(trails, null, 2),
);
console.log(`✅ Exported ${trails.length} trails to trilha_app/assets/data/trails.json`);
