import { NextResponse } from "next/server";
import { prisma } from "@/lib/prisma";

export async function GET() {
  const trails = await prisma.trail.findMany({
    orderBy: { order: "asc" },
    include: {
      modules: {
        include: {
          missions: {
            select: { id: true, slug: true, title: true, type: true, xpReward: true, order: true },
            orderBy: { order: "asc" },
          },
        },
        orderBy: { order: "asc" },
      },
    },
  });

  return NextResponse.json(trails);
}
