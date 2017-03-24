CREATE TABLE "schema_migrations" ("version" varchar NOT NULL);
CREATE UNIQUE INDEX "unique_schema_migrations" ON "schema_migrations" ("version");
CREATE TABLE "annotations_locations" ("annotation_id" integer NOT NULL, "location_id" integer NOT NULL);
CREATE TABLE "annotations_videos" ("annotation_id" integer NOT NULL, "video_id" integer NOT NULL);
CREATE TABLE "locations" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL, "location" text NOT NULL);
CREATE TABLE "locations_videos" ("video_id" integer NOT NULL, "location_id" integer NOT NULL);
CREATE TABLE "semantic_tags" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "tag" varchar, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "users" (
	`id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`name`	varchar,
	`email`	varchar,
	`password_digest`	varchar,
	`created_at`	datetime NOT NULL,
	`updated_at`	datetime NOT NULL
);
CREATE TABLE "videos" (
	`id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`title`	varchar,
	`author`	varchar,
	`created_at`	datetime NOT NULL,
	`updated_at`	datetime NOT NULL,
	`location_id`	INTEGER
);
CREATE TABLE "annotators" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "dummythings" ("id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, "created_at" datetime NOT NULL, "updated_at" datetime NOT NULL);
CREATE TABLE "annotations" (
	`id`	INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
	`annotation`	varchar NOT NULL,
	`created_at`	datetime NOT NULL,
	`updated_at`	datetime NOT NULL,
	`video_id`	integer,
	`location_id`	integer,
	`tag_id`	INTEGER,
	`user_id`	INTEGER,
	`polygon`	TEXT,
	`beginTime`	INTEGER,
	`endTime`	INTEGER
, "pointsArray" ARRAY, "deprecated" boolean, "prev_anno_ID" int);
INSERT INTO schema_migrations (version) VALUES ('20170317130458');

INSERT INTO schema_migrations (version) VALUES ('20170317163906');

