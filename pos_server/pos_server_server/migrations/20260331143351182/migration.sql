BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "settings" (
    "id" bigserial PRIMARY KEY,
    "taxRate" double precision NOT NULL,
    "serviceCharge" double precision NOT NULL,
    "currencySymbol" text NOT NULL,
    "orderDelayThreshold" bigint NOT NULL,
    "updatedAt" timestamp without time zone
);


--
-- MIGRATION VERSION FOR pos_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('pos_server', '20260331143351182', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260331143351182', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260129180959368', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129180959368', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260213194423028', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260213194423028', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260129181112269', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260129181112269', "timestamp" = now();


COMMIT;
