DROP TABLE if exists appointments CASCADE;

DROP TABLE if exists med_conditions CASCADE;

DROP TABLE if exists patients_to_sites CASCADE;

DROP TABLE if exists patients CASCADE;

DROP TABLE if exists doctors CASCADE;

DROP TABLE if exists sites CASCADE;

DROP TABLE if exists departments CASCADE;

DROP TABLE if exists clinics CASCADE;

DROP TABLE if exists persons CASCADE;

DROP TABLE if exists infections CASCADE;

DROP TABLE if exists viruses CASCADE;

DROP TYPE if exists gender;

drop TYPE if exists condition CASCADE;

BEGIN;

CREATE TYPE gender AS ENUM('M', 'F');

CREATE TYPE condition AS ENUM('OK', 'NOT OK', 'CRITICAL', 'DEAD');

CREATE TABLE
  persons (
    id SERIAL PRIMARY KEY,
    gender gender NOT NULL,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL
  );

CREATE TABLE
  clinics (id serial PRIMARY KEY, name varchar(80) NOT NULL);

CREATE TABLE
  departments (
    id serial PRIMARY KEY,
    clinic_id INTEGER,
    FOREIGN KEY (clinic_id) REFERENCES clinics (id),
    name varchar(80) NOT NULL
  );

CREATE TABLE
  sites (
    id serial PRIMARY KEY,
    department_id INTEGER,
    FOREIGN KEY (department_id) REFERENCES departments (id),
    number INTEGER NOT NULL CHECK (number > 0)
  );

CREATE TABLE
  patients (
    id INTEGER NOT NULL,
    FOREIGN KEY (id) REFERENCES persons (id),
    PRIMARY KEY (id),
    police varchar(80) NOT NULL
  );

create table
  med_conditions (
    person_id INTEGER,
    FOREIGN KEY (person_id) REFERENCES persons (id),
    primary key (person_id),
    condition condition not null
  );

CREATE TABLE
  doctors (
    id INTEGER NOT NULL,
    FOREIGN KEY (id) REFERENCES persons (id),
    PRIMARY KEY (id),
    site_id INTEGER,
    FOREIGN KEY (site_id) REFERENCES sites (id),
    specialty varchar(80) NOT NULL
  );

CREATE TABLE
  appointments (
    id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients (id),
    doctor_id INTEGER NOT NULL,
    FOREIGN KEY (doctor_id) REFERENCES doctors (id),
    date TIMESTAMP NOT NULL,
    check (patient_id != doctor_id)
  );

CREATE TABLE
  patients_to_sites (
    patient_id INTEGER NOT NULL,
    FOREIGN KEY (patient_id) REFERENCES patients (id),
    site_id INTEGER NOT NULL,
    FOREIGN KEY (site_id) REFERENCES sites (id),
    PRIMARY KEY (patient_id, site_id)
  );

CREATE TABLE
  viruses (
    id SERIAL PRIMARY KEY,
    name varchar(80) NOT NULL,
    virality INTEGER NOT NULL CHECK (virality BETWEEN 0 AND 100),
    lethality INTEGER NOT NULL default 0 CHECK (virality BETWEEN 0 AND 100),
    spotted_date timestamp not null,
    duration_days int not null
  );

CREATE TABLE
  infections (
    id SERIAL PRIMARY KEY,
    person_id INTEGER NOT NULL,
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    infected_by INTEGER not null,
    FOREIGN KEY (infected_by) REFERENCES persons (id),
    virus_id INTEGER NOT NULL,
    FOREIGN KEY (virus_id) REFERENCES viruses (id)
  );

COMMIT;

create
or replace function create_med_condition () returns trigger as $$
begin
  insert into med_conditions (person_id, condition) values (new.id, 'OK');
  return new;
end;
$$ language plpgsql;

create
or replace trigger create_med_condition_trigger
after insert on persons for each row
execute procedure create_med_condition ();