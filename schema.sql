-- If you want to run this schema repeatedly you'll need to drop
-- the table before re-creating it. Note that you'll lose any
-- data if you drop and add a table:

DROP TABLE IF EXISTS contacts CASCADE;

-- Define your schema here:

CREATE TABLE contacts (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100)
);

DROP TABLE IF EXISTS skills;

CREATE TABLE skills (
  id SERIAL PRIMARY KEY,
  description VARCHAR(200),
  contact_id INTEGER REFERENCES contacts
);
