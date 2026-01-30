BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "coach" ADD COLUMN "elevenLabsModelId" text;
ALTER TABLE "coach" ADD COLUMN "voiceStability" double precision;
ALTER TABLE "coach" ADD COLUMN "voiceSimilarity" double precision;
ALTER TABLE "coach" ADD COLUMN "voiceStyle" double precision;
ALTER TABLE "coach" ADD COLUMN "voiceSpeed" double precision;
ALTER TABLE "coach" ADD COLUMN "useSpeakerBoost" boolean;

--
-- MIGRATION VERSION FOR my_coach_serverpod_challenge
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('my_coach_serverpod_challenge', '20260126190013107', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260126190013107', "timestamp" = now();

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
