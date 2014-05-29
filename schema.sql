
CREATE TABLE posts(
  id serial PRIMARY KEY,
  title varchar(1000) NOT NULL,
  description varchar(5000) NOT NULL,
  url varchar (200) NOT NULL,
  created_at TIMESTAMP NOT NULL
);

CREATE TABLE comments(
  id serial PRIMARY KEY,
  post_id Integer references posts(id),
  description varchar(5000) NOT NULL,
  created_at TIMESTAMP NOT NULL
);
