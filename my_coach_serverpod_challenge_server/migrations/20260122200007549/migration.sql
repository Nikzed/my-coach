BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "subtask" (
    "id" bigserial PRIMARY KEY,
    "taskId" bigint NOT NULL,
    "name" text NOT NULL,
    "orderIndex" bigint NOT NULL,
    "isCompleted" boolean NOT NULL,
    "completedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "subtask_task_idx" ON "subtask" USING btree ("taskId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "task" DROP COLUMN "reminderSent";
--
-- ACTION CREATE TABLE
--
CREATE TABLE "task_reminder" (
    "id" bigserial PRIMARY KEY,
    "taskId" bigint NOT NULL,
    "minutesBefore" bigint NOT NULL,
    "isSent" boolean NOT NULL,
    "sentAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "task_reminder_task_idx" ON "task_reminder" USING btree ("taskId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "voice_task_draft" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "sessionId" text NOT NULL,
    "transcribedText" text NOT NULL,
    "parsedName" text,
    "parsedDescription" text,
    "parsedDueTime" text,
    "suggestedCoachId" bigint,
    "coachConfidence" double precision,
    "parsedSubtasks" text,
    "parsedReminders" text,
    "status" text NOT NULL,
    "clarificationQuestion" text,
    "conversationHistory" text,
    "createdAt" timestamp without time zone NOT NULL,
    "expiresAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "voice_draft_user_idx" ON "voice_task_draft" USING btree ("userId");
CREATE INDEX "voice_draft_session_idx" ON "voice_task_draft" USING btree ("sessionId");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "subtask"
    ADD CONSTRAINT "subtask_fk_0"
    FOREIGN KEY("taskId")
    REFERENCES "task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "task_reminder"
    ADD CONSTRAINT "task_reminder_fk_0"
    FOREIGN KEY("taskId")
    REFERENCES "task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR my_coach_serverpod_challenge
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('my_coach_serverpod_challenge', '20260122200007549', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260122200007549', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20251208110333922-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110333922-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260109031533194', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260109031533194', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
