CREATE DATABASE linkedin;

USE linkedin;

CREATE TABLE users (
  id INT AUTO_INCREMENT,
  first_name VARCHAR(32) NOT NULL,
  last_name VARCHAR(32) NOT NULL,
  username VARCHAR(32) NOT NULL UNIQUE,
  password VARCHAR(32) NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE schools (
  id INT AUTO_INCREMENT,
  name VARCHAR(32) NOT NULL,
  type ENUM('Primary', 'Secondary', 'Higher Education') NOT NULL,
  location VARCHAR(100) NOT NULL,
  year SMALLINT NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE companies (
  id INT AUTO_INCREMENT,
  name VARCHAR(50) NOT NULL,
  industry ENUM('Technology', 'Education', 'Business') NOT NULL,
  location VARCHAR(100) NOT NULL,
  PRIMARY KEY(id)
);

CREATE TABLE people_connection (
  user_id INT,
  connected_id INT,
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(connected_id) REFERENCES users(id)
);

CREATE TABLE school_connection (
  user_id INT,
  school_id INT,
  start_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  end_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  type VARCHAR(32) NOT NULL,
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(school_id) REFERENCES schools(id)
);

CREATE TABLE company_connection (
  user_id INT,
  company_id INT,
  start_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  end_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  title VARCHAR(50) NOT NULL,
  FOREIGN KEY(user_id) REFERENCES users(id),
  FOREIGN KEY(company_id) REFERENCES companies(id)
);