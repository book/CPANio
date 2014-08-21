CREATE TABLE once_a_bins  ( bin text NOT NULL, author text NOT NULL default '', count int NOT NULL DEFAULT 0, PRIMARY KEY ( bin, author ) );
CREATE TABLE once_a_day   ( contest text NOT NULL, rank int NOT NULL, author text NOT NULL, count int NOT NULL, active boolean NOT NULL, safe boolean NOT NULL );
CREATE TABLE once_a_month ( contest text NOT NULL, rank int NOT NULL, author text NOT NULL, count int NOT NULL, active boolean NOT NULL, safe boolean NOT NULL );
CREATE TABLE once_a_week  ( contest text NOT NULL, rank int NOT NULL, author text NOT NULL, count int NOT NULL, active boolean NOT NULL, safe boolean NOT NULL );
CREATE TABLE timestamps   ( board text UNIQUE NOT NULL, latest_update datetime NOT NULL, PRIMARY KEY ( board ) );
