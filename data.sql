BEGIN;

INSERT INTO
  persons (gender, first_name, last_name)
VALUES
  ('M', 'John', 'Doe'),
  ('F', 'Jane', 'Smith'),
  ('M', 'Michael', 'Johnson'),
  ('F', 'Emily', 'Brown'),
  ('M', 'David', 'Davis'),
  ('F', 'Jessica', 'Wilson'),
  ('M', 'Christopher', 'Martinez'),
  ('F', 'Sarah', 'Taylor'),
  ('M', 'Matthew', 'Anderson'),
  ('F', 'Amanda', 'Thomas'),
  ('M', 'Joe', 'Biden');

INSERT INTO
  clinics (name)
VALUES
  ('Clinic A'),
  ('Clinic B');

INSERT INTO
  departments (clinic_id, name)
VALUES
  (1, 'Department X'),
  (1, 'Department Y'),
  (2, 'Department Z');

INSERT INTO
  sites (department_id, number)
VALUES
  (1, 101),
  (1, 102),
  (2, 201),
  (3, 301);

INSERT INTO
  patients (id, police)
VALUES
  (1, 'P123'),
  (2, 'P456'),
  (3, 'P789'),
  (4, 'P012'),
  (5, 'P345'),
  (6, 'P678'),
  (7, 'P901'),
  (8, 'P234'),
  (9, 'P567'),
  (10, 'P890'),
  (11, 'P891');

INSERT INTO
  doctors (id, site_id, specialty)
VALUES
  (3, 1, 'Cardiologist'),
  (4, 2, 'Pediatrician'),
  (5, 2, 'Dermatologist'),
  (6, 3, 'Neurologist'),
  (7, 4, 'Oncologist');

INSERT INTO
  appointments (patient_id, doctor_id, date)
VALUES
  (1, 4, '2024-05-01 09:00:00'),
  (2, 4, '2024-05-02 10:00:00'),
  (3, 4, '2024-05-03 11:00:00'),
  (4, 3, '2024-05-04 12:00:00'),
  (1, 4, '2024-05-05 13:00:00'),
  (7, 5, '2024-05-05 14:00:00'), -- coworker infect test
  (7, 4, '2024-05-07 15:00:00'),
  (8, 4, '2024-05-08 16:00:00'),
  (9, 4, '2024-05-09 17:00:00'),
  (10, 4, '2024-05-10 18:00:00'),
  (3, 4, '2024-05-11 09:00:00'),
  (4, 3, '2024-05-12 10:00:00'),
  (5, 4, '2024-05-13 11:00:00'),
  (6, 4, '2024-05-14 12:00:00'),
  (7, 4, '2024-05-15 13:00:00'),
  (8, 4, '2024-05-16 14:00:00'),
  (9, 4, '2024-05-17 15:00:00'),
  (10, 4, '2024-05-18 16:00:00'),
  (1, 4, '2024-05-19 17:00:00'),
  (2, 4, '2024-05-20 18:00:00'),
  (5, 4, '2024-05-21 09:00:00'),
  (6, 4, '2024-05-22 10:00:00'),
  (7, 4, '2024-05-23 11:00:00'),
  (8, 4, '2024-05-24 12:00:00'),
  (9, 4, '2024-05-25 13:00:00'),
  (10, 4, '2024-05-26 14:00:00'),
  (11, 4, '2024-05-27 14:00:00'); -- finish infections test

COMMIT;