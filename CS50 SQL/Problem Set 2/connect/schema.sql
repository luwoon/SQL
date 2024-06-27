CREATE TABLE users (
    id INTEGER,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    username TEXT NOT NULL UNIQUE,
    password TEXT NOT NULL,
    PRIMARY KEY(id)
);

CREATE TABLE schools (
    id INTEGER,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    location TEXT NOT NULL,
    year INTEGER NOT NULL,
    PRIMARY KEY(id)
);

CREATE TABLE companies (
    id INTEGER,
    name TEXT NOT NULL,
    industry TEXT NOT NULL,
    location TEXT NOT NULL,
    PRIMARY KEY(id)
);

CREATE TABLE people_connection (
    user_id INTEGER,
    connected_id INTEGER,
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(connected_id) REFERENCES users(id)
);

CREATE TABLE school_connection (
    user_id INTEGER,
    school_id INTEGER,
    start_date NUMERIC NOT NULL,
    end_date NUMERIC,
    type TEXT NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(school_id) REFERENCES schools(id)
);

CREATE TABLE company_connection (
    user_id INTEGER,
    company_id INTEGER,
    start_date NUMERIC NOT NULL,
    end_date NUMERIC,
    title TEXT NOT NULL,
    FOREIGN KEY(user_id) REFERENCES users(id),
    FOREIGN KEY(company_id) REFERENCES companies(id)
);