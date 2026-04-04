BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "pos_orders" ADD COLUMN "scheduledTime" timestamp without time zone;
--
-- ACTION CREATE TABLE
--
CREATE TABLE "reservations" (
    "id" bigserial PRIMARY KEY,
    "tableNumber" text NOT NULL,
    "customerName" text NOT NULL,
    "customerPhone" text,
    "reservationTime" timestamp without time zone NOT NULL,
    "guestCount" bigint NOT NULL,
    "status" text NOT NULL DEFAULT 'Pending'::text,
    "createdAt" timestamp without time zone NOT NULL,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE INDEX "reservations_table_time_idx" ON "reservations" USING btree ("tableNumber", "reservationTime");


--
-- MIGRATION VERSION FOR pos_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('pos_server', '20260404123558017', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260404123558017', "timestamp" = now();

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
