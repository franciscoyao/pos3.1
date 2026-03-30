BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "bills" (
    "id" bigserial PRIMARY KEY,
    "billNumber" text NOT NULL,
    "orderType" text,
    "tableNo" text,
    "waiterName" text,
    "paymentMethod" text,
    "taxNumber" text,
    "subtotal" double precision NOT NULL DEFAULT 0,
    "taxAmount" double precision NOT NULL DEFAULT 0,
    "serviceAmount" double precision NOT NULL DEFAULT 0,
    "tipAmount" double precision NOT NULL DEFAULT 0,
    "total" double precision NOT NULL,
    "createdAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "bills_bill_number_idx" ON "bills" USING btree ("billNumber");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "categories" (
    "id" bigserial PRIMARY KEY,
    "name" text NOT NULL,
    "sortOrder" bigint NOT NULL DEFAULT 0,
    "station" text,
    "orderType" text NOT NULL DEFAULT 'Both'::text
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "order_items" (
    "id" bigserial PRIMARY KEY,
    "orderId" bigint NOT NULL,
    "productId" bigint NOT NULL,
    "productName" text,
    "productStation" text,
    "quantity" bigint NOT NULL,
    "price" double precision NOT NULL,
    "totalPrice" double precision NOT NULL DEFAULT 0,
    "notes" text,
    "extras" text DEFAULT '[]'::text
);

-- Indexes
CREATE INDEX "order_items_order_idx" ON "order_items" USING btree ("orderId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "pos_orders" (
    "id" bigserial PRIMARY KEY,
    "billId" bigint,
    "orderCode" text,
    "orderType" text,
    "tableNo" text,
    "status" text NOT NULL DEFAULT 'Pending'::text,
    "waiterName" text,
    "subtotal" double precision NOT NULL DEFAULT 0,
    "taxAmount" double precision NOT NULL DEFAULT 0,
    "serviceAmount" double precision NOT NULL DEFAULT 0,
    "tipAmount" double precision NOT NULL DEFAULT 0,
    "total" double precision NOT NULL,
    "createdAt" timestamp without time zone,
    "updatedAt" timestamp without time zone,
    "items" json
);

-- Indexes
CREATE UNIQUE INDEX "pos_orders_order_code_idx" ON "pos_orders" USING btree ("orderCode");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "pos_users" (
    "id" bigserial PRIMARY KEY,
    "fullName" text,
    "username" text NOT NULL,
    "pin" text,
    "role" text NOT NULL,
    "status" text NOT NULL DEFAULT 'Active'::text,
    "isDefault" boolean NOT NULL DEFAULT false,
    "createdAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "pos_users_username_idx" ON "pos_users" USING btree ("username");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "product_extras" (
    "id" bigserial PRIMARY KEY,
    "productId" bigint NOT NULL,
    "name" text NOT NULL,
    "price" double precision NOT NULL DEFAULT 0
);

-- Indexes
CREATE INDEX "product_extras_product_idx" ON "product_extras" USING btree ("productId");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "products" (
    "id" bigserial PRIMARY KEY,
    "categoryId" bigint,
    "subcategoryId" bigint,
    "itemCode" text,
    "name" text NOT NULL,
    "price" double precision NOT NULL,
    "imageUrl" text,
    "station" text,
    "type" text,
    "isAvailable" boolean NOT NULL DEFAULT true,
    "allowPriceEdit" boolean NOT NULL DEFAULT false,
    "isDeleted" boolean NOT NULL DEFAULT false,
    "extras" json
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "restaurant_tables" (
    "id" bigserial PRIMARY KEY,
    "tableNumber" text NOT NULL,
    "status" text NOT NULL DEFAULT 'Available'::text,
    "orderCode" text,
    "guestCount" bigint NOT NULL DEFAULT 0,
    "updatedAt" timestamp without time zone
);

-- Indexes
CREATE UNIQUE INDEX "restaurant_tables_number_idx" ON "restaurant_tables" USING btree ("tableNumber");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "subcategories" (
    "id" bigserial PRIMARY KEY,
    "categoryId" bigint NOT NULL,
    "name" text NOT NULL,
    "sortOrder" bigint NOT NULL DEFAULT 0
);

-- Indexes
CREATE INDEX "subcategories_category_idx" ON "subcategories" USING btree ("categoryId");


--
-- MIGRATION VERSION FOR pos_server
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('pos_server', '20260330133658902', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260330133658902', "timestamp" = now();

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
