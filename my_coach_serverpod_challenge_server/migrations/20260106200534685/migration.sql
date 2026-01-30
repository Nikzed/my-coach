BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "coach" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "description" text NOT NULL,
    "personalityPrompt" text NOT NULL,
    "elevenLabsVoiceId" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "coach_message" (
    "id" bigserial PRIMARY KEY,
    "taskId" bigint NOT NULL,
    "coachId" bigint NOT NULL,
    "textContent" text NOT NULL,
    "audioStoragePath" text,
    "generatedAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "coach_message_task_idx" ON "coach_message" USING btree ("taskId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "task" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "coachId" bigint NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "dueTime" timestamp without time zone,
    "isCompleted" boolean NOT NULL,
    "completedAt" timestamp without time zone,
    "reminderSent" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);

-- Indexes
CREATE INDEX "task_user_idx" ON "task" USING btree ("userId");
CREATE INDEX "task_due_time_idx" ON "task" USING btree ("dueTime");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_device" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "fcmToken" text NOT NULL,
    "platform" text NOT NULL,
    "lastUpdated" timestamp without time zone NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "user_device_user_idx" ON "user_device" USING btree ("userId");
CREATE UNIQUE INDEX "user_device_fcm_token_idx" ON "user_device" USING btree ("fcmToken");

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "coach_message"
    ADD CONSTRAINT "coach_message_fk_0"
    FOREIGN KEY("taskId")
    REFERENCES "task"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;
ALTER TABLE ONLY "coach_message"
    ADD CONSTRAINT "coach_message_fk_1"
    FOREIGN KEY("coachId")
    REFERENCES "coach"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;

--
-- ACTION CREATE FOREIGN KEY
--
ALTER TABLE ONLY "task"
    ADD CONSTRAINT "task_fk_0"
    FOREIGN KEY("coachId")
    REFERENCES "coach"("id")
    ON DELETE NO ACTION
    ON UPDATE NO ACTION;


--
-- MIGRATION VERSION FOR my_coach_serverpod_challenge
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('my_coach_serverpod_challenge', '20260106200534685', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260106200534685', "timestamp" = now();

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
    VALUES ('serverpod_auth_idp', '20251208110420531-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110420531-v3-0-0', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
