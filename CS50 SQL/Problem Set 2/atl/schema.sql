CREATE TABLE passengers (
    id INTEGER,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    age INTEGER NOT NULL,
    PRIMARY KEY(id)
);

CREATE TABLE check_ins (
    id INTEGER,
    passenger_id INTEGER,
    datetime NUMERIC NOT NULL,
    flight_id INTEGER,
    PRIMARY KEY(id)
    FOREIGN KEY(passenger_id) REFERENCES passengers(id),
    FOREIGN KEY(flight_id) REFERENCES flights(id)
);

CREATE TABLE airlines (
    id INTEGER,
    name TEXT NOT NULL UNIQUE,
    concourse TEXT NOT NULL CHECK(concourse IN ('A', 'B', 'C', 'D', 'E', 'F', 'T')),
    PRIMARY KEY(id)
);

CREATE TABLE flights (
    id INTEGER,
    number INTEGER NOT NULL,
    airline_id INTEGER,
    depart_code TEXT NOT NULL,
    headed_code TEXT NOT NULL,
    depart_datetime NUMERIC NOT NULL,
    expected_arrival_datetime NUMERIC NOT NULL,
    PRIMARY KEY(id),
    FOREIGN KEY(airline_id) REFERENCES airlines(id)
);