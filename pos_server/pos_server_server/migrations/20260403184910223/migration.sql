BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "bill_items" (
    "id" bigserial PRIMARY KEY,
    "billId" bigint NOT NULL,
    "productName" text,
    "quantity" bigint NOT NULL,
    "price" double precision NOT NULL,
    "totalPrice" double precision NOT NULL DEFAULT 0
);

-- Indexes
CREATE INDEX "bill_items_bill_idx" ON "bill_items" USING btree ("billId");

--
-- ACTION ALTER TABLE
--
ALTER TABLE "pos_orders" ADD COLUMN "taxNumber" text;

--
-- MIGRATION VERSION FOR pos_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('pos_server', '20260403184910223', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260403184910223', "timestamp" = now();

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
