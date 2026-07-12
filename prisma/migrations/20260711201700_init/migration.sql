-- CreateTable
CREATE TABLE "Trail" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "slug" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "icon" TEXT NOT NULL DEFAULT '📖',
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- CreateTable
CREATE TABLE "Module" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "trailId" TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "icon" TEXT NOT NULL,
    CONSTRAINT "Module_trailId_fkey" FOREIGN KEY ("trailId") REFERENCES "Trail" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Mission" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "moduleId" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "intro" TEXT NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'lesson',
    "xpReward" INTEGER NOT NULL DEFAULT 50,
    CONSTRAINT "Mission_moduleId_fkey" FOREIGN KEY ("moduleId") REFERENCES "Module" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateTable
CREATE TABLE "Question" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "missionId" TEXT NOT NULL,
    "order" INTEGER NOT NULL,
    "type" TEXT NOT NULL DEFAULT 'multiple_choice',
    "question" TEXT NOT NULL,
    "options" TEXT NOT NULL,
    "correctOptionId" TEXT NOT NULL,
    "feedbackCorrect" TEXT NOT NULL,
    "feedbackWrong" TEXT NOT NULL,
    "verseRef" TEXT,
    CONSTRAINT "Question_missionId_fkey" FOREIGN KEY ("missionId") REFERENCES "Mission" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CreateIndex
CREATE UNIQUE INDEX "Trail_slug_key" ON "Trail"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "Module_trailId_order_key" ON "Module"("trailId", "order");

-- CreateIndex
CREATE UNIQUE INDEX "Mission_slug_key" ON "Mission"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "Mission_moduleId_order_key" ON "Mission"("moduleId", "order");

-- CreateIndex
CREATE UNIQUE INDEX "Question_missionId_order_key" ON "Question"("missionId", "order");
