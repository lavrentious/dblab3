# Лютый триггер 3ЛР, БД 1 курс
<p align="center">
  <img src="https://se.ifmo.ru/documents/1609903/1613524/maxresdefault.jpg/daa7193a-ceb1-7378-6c5a-ca905edf72ea?t=1631888870500" />
</p>

## Запуск
`psql -f init.sql && psql -f data.sql && psql -f virus.sql` - инициализация базы, тестовых данных и процедур

## Примеры вирусов
`insert into viruses (name, virality, lethality, duration_days, spotted_date) values ('EBALA', 75, 100, 1, '2024-05-01 01:00:00');` - 100% летальный, но пациенты слишком быстро умирают

`insert into viruses (name, virality, lethality, duration_days, spotted_date) values ('LGBT', 100, 5, 28, '2024-05-01 01:00:00');` - 100% заразный, но нелетальный

`insert into viruses (name, virality, lethality, duration_days, spotted_date) values ('COVID', 75, 40, 7, '2024-05-01 01:00:00');` - нормальный вэрус

<hr/>

`select mc.person_id, i.start_date, i.end_date, i.infected_by, i.virus_id, mc.condition from infections i right join med_conditions mc using(person_id);` - просмотр результатов