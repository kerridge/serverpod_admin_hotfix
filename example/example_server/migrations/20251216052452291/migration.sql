BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "posts" ADD COLUMN "isPublished" boolean NOT NULL DEFAULT false;

--
-- MIGRATION VERSION FOR example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('example', '20251216052452291', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251216052452291', "timestamp" = now();

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
-- MIGRATION VERSION FOR serverpod_admin
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_admin', '20251216044017986', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251216044017986', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
