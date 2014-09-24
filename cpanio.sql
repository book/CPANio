CREATE TABLE once_a_day   ( game text NOT NULL, contest text NOT NULL, rank int NOT NULL, author text NOT NULL, count int NOT NULL, active boolean NOT NULL, safe boolean NOT NULL, fallen boolean NOT NULL );
CREATE TABLE once_a_month ( game text NOT NULL, contest text NOT NULL, rank int NOT NULL, author text NOT NULL, count int NOT NULL, active boolean NOT NULL, safe boolean NOT NULL, fallen boolean NOT NULL );
CREATE TABLE once_a_week  ( game text NOT NULL, contest text NOT NULL, rank int NOT NULL, author text NOT NULL, count int NOT NULL, active boolean NOT NULL, safe boolean NOT NULL, fallen boolean NOT NULL );
CREATE TABLE release_bins ( bin text NOT NULL, author text NOT NULL default '', count int NOT NULL DEFAULT 0, PRIMARY KEY ( bin, author ) );
CREATE TABLE timestamps   ( game text UNIQUE NOT NULL, latest_update datetime NOT NULL, PRIMARY KEY ( game ) );
