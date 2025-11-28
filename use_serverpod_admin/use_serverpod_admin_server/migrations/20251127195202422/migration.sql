BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "posts" (
    "id" bigserial PRIMARY KEY,
    "title" text NOT NULL,
    "description" text NOT NULL,
    "date" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR use_serverpod_admin
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('use_serverpod_admin', '20251127195202422', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251127195202422', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20240516151843329', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20240516151843329', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_admin
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_admin', '20251115114801095', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20251115114801095', "timestamp" = now();


COMMIT;
