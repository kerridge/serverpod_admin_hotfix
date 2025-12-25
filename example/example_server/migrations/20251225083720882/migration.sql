BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "admin_scope" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "admin_scope" (
    "id" bigserial PRIMARY KEY,
    "userId" text NOT NULL,
    "isStaff" boolean NOT NULL,
    "isSuperuser" boolean NOT NULL
);

-- Indexes
CREATE UNIQUE INDEX "uniq_user" ON "admin_scope" USING btree ("userId");


--
-- MIGRATION VERSION FOR example
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('example', '20251225083720882', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251225083720882', "timestamp" = now();

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
    VALUES ('serverpod_admin', '20251225083629049', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251225083629049', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20251208110412389-v3-0-0', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251208110412389-v3-0-0', "timestamp" = now();


COMMIT;
