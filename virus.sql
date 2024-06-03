-- psql -f init.sql && psql -f data.sql && psql -f virus.sql
drop procedure if exists start_virus;

drop procedure if exists infect_zero_patient;

drop function if exists is_alive;

create or replace function is_alive(p_id int)
returns boolean
as $$
begin
	return (select condition from med_conditions mc where mc.person_id = p_id) != 'DEAD';
end;
$$ language plpgsql;

create or replace
procedure try_to_infect(by_name text, by_id int, who_name text, who_id int, virus record, infection_date timestamp)
as $$
begin
	if random() * 99 + 1 < virus.virality then
		raise notice '% % infects % %', by_name, by_id, who_name, who_id;
		insert into infections (person_id, infected_by, start_date, virus_id) values (who_id, by_id, infection_date, virus.id);
	else
		raise notice '% % failed to infect % %', by_name, by_id, who_name, who_id;
	end if;
end;
$$ language plpgsql;

create
or replace procedure start_virus (zero_patient record, virus record) as $$
declare
	appointment appointments%rowtype;
	coworker_appointment appointments%rowtype;
	infection infections%rowtype;
	patient_alive boolean;
	doctor_alive boolean;
	patient_infected boolean;
	doctor_infected boolean;
	virus_id int;
begin
	virus_id := virus.id;
	-- current infected people view
	create or replace temporary view current_infected as
	select * from infections i where i.virus_id = virus_id and i.end_date is null;

	insert into infections (person_id, infected_by, start_date, virus_id) values (zero_patient.id, zero_patient.id, virus.spotted_date, virus.id);

	-- propagating
	for appointment in 
	select a.*, doctors.site_id from appointments as a
	join doctors on a.doctor_id = doctors.id
	where a.date >= virus.spotted_date
	order by a.date asc
	loop
		raise notice '[%]:', appointment.date;
		patient_infected := appointment.patient_id in (select person_id from current_infected);
		doctor_infected := appointment.doctor_id in (select person_id from current_infected);

		if not is_alive(appointment.doctor_id) or not is_alive(appointment.patient_id) then
			continue;
		end if;

		-- patient/doctor infect each other at appointment
		if (patient_infected != doctor_infected) then
			if patient_infected then
				-- infected patient comes to appointment
				
				if appointment.date >= ((select i.start_date from current_infected i where i.person_id = appointment.patient_id) + (virus.duration_days || ' days')::interval) then
					-- patient may have died

					raise notice '% was infected at %, now is %', appointment.patient_id, (select i.start_date from current_infected i where i.person_id = appointment.patient_id), appointment.date;
					if random() * 99 + 1 < virus.lethality then
						raise notice 'patient % is ded :(', appointment.patient_id;
						update med_conditions set condition = 'DEAD' where person_id = appointment.patient_id;
					else
						raise notice 'patient % survived the virus :)', appointment.patient_id;
					end if;
					update infections i set end_date = i.start_date + (virus.duration_days || ' days')::interval where i.virus_id = virus.id and i.person_id = appointment.patient_id;
					continue;
				end if;

				call try_to_infect('patient', appointment.patient_id, 'doctor', appointment.doctor_id, virus, appointment.date);
			elsif doctor_infected then
			-- infected doctor comes to appointment

				if appointment.date >= ((select i.start_date from current_infected i where i.person_id = appointment.doctor_id) + (virus.duration_days || ' days')::interval) then
					-- doctor may have died
					if random() * 99 + 1 < virus.lethality then
						raise notice 'doctor % is ded :(', appointment.doctor_id;
						update med_conditions set condition = 'DEAD' where person_id = appointment.doctor_id;
					else
						raise notice 'doctor % survived the virus :)', appointment.doctor_id;
					end if;
					update infections i set end_date = i.start_date + (virus.duration_days || ' days')::interval where i.virus_id = virus.id and i.person_id = appointment.doctor_id;
					continue;
				end if;

				call try_to_infect('doctor', appointment.doctor_id, 'patient', appointment.patient_id, virus, appointment.date);
			end if;
		end if;

		-- infect coworkers at site
		if appointment.doctor_id in (select person_id from current_infected) then
			for coworker_appointment in
			select ca.*, d.site_id from appointments as ca
			join doctors d on ca.doctor_id = d.id
			where ca.date > appointment.date and extract(day from ca.date) = extract(day from appointment.date) -- if doctor meets his coworker after being infected the same day
			loop
				if not exists (select 1 from infections i where i.virus_id = virus.id and i.person_id = coworker_appointment.doctor_id) and is_alive(coworker_appointment.doctor_id) then
					-- if coworker is infectable
					call try_to_infect('doctor', appointment.doctor_id, 'coworker', coworker_appointment.doctor_id, virus, coworker_appointment.date);
				end if;
			end loop;
		end if;
	end loop;

	-- ДОБИТЬ ВЫЖИВШИХ
	for infection in 
	select * from current_infected i
	loop
		raise notice 'finishing person %', infection.person_id;
		if random() * 99 + 1 < virus.lethality then
			raise notice 'person % is ded :(', infection.person_id;
			update med_conditions set condition = 'DEAD' where person_id = infection.person_id;
		else
			raise notice 'person % survived the virus :)', infection.person_id;
		end if;
		update current_infected i set end_date = (infection.start_date) + (virus.duration_days || ' days')::interval
		where i.person_id = infection.person_id;
	end loop;
end;
$$ language plpgsql;

create
or replace procedure infect_zero_patient (virus record) as $$
declare
  zero_patient persons%rowtype;
	appointed_doctor_id integer;
begin
	select * from persons into zero_patient
	order by random()
	limit 1;
	if zero_patient is not null then
		raise notice 'using zero patient %', zero_patient;
		raise notice 'using virus %', virus;

		select d.id into appointed_doctor_id from doctors d where d.id != zero_patient.id order by random() limit 1;
		raise notice 'zero patient goes to doctor %', appointed_doctor_id;
		insert into appointments (doctor_id, patient_id, date) values (appointed_doctor_id, zero_patient.id, virus.spotted_date);


		call start_virus(zero_patient, virus);
	else
		raise notice 'zero patient not found :) fuck you virus %!', virus.name;
	end if;
end;
$$ language plpgsql;

create
or replace function virus_trigger () returns trigger as $$
begin
  raise notice 'virus % appeared', new.name;
	call infect_zero_patient(new);
  return new;
end;
$$ language plpgsql;

create
or replace trigger on_virus_appearance
after insert on viruses for each row
execute procedure virus_trigger ();