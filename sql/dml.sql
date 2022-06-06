-- Insert & Update

-- 1 --
prepare user_insert(varchar, varchar, varchar, varchar, userstatus, varchar, usertype, boolean, timestamp)
    as insert into "user" (firstname, lastname, mail, password, status, phone, type, public, joinedat)
       values ($1, $2, $3, $4, $5, $6, $7, $8, $9);

begin;
execute user_insert('علی', 'غلامی', 'ali@gmail.com', '1234', 'active', '09181234458', 'developer', true, now());
execute user_insert('زهره', 'رسولی', 'zohre@gmail.com', '1234', 'active', '09123564485', 'developer', true, now());
execute user_insert('الهام', 'نیایشی', 'eli@gmail.com', '1234', 'active', '09154863951', 'developer', true, now());
execute user_insert('رضا', 'ملکی', 'rez.mal@gmail.com', '1234', 'active', '09218585858', 'developer', true, now());
execute user_insert('مرتضی', 'مولایی', 'morri@gmail.com', '1234', 'active', '09369696969', 'developer', true, now());
execute user_insert('سعید', 'حجازی', 'saeed@gmail.com', '1234', 'active', '09019054811', 'developer', true, now());
execute user_insert('محمد', 'رهنما', 'mohammad@gmail.com', '1234', 'active', '09151250051', 'developer', true, now());
execute user_insert('آرمان', 'فدایی', 'arman@gmail.com', '1234', 'active', '09511225285', 'developer', true, now());
execute user_insert('محمد', 'سجادی', 'm.sajjadi@gmail.com', '1234', 'active', '09191515582', 'developer', true, now());
execute user_insert('علی', 'محمدی', 'a.mohammadi@gmail.com', '1234', 'active', '09171515278', 'developer', true, now());
end;

-- 2 --
begin;
insert into state(id, name)
values (1, 'تهران');
insert into city(name, state)
values ('تهران', 1);
insert into institute(name, type, city)
values ('خواجه نصیرالدین طوسی', 'university', 1);
insert into class(title, professor, description, password, institute, year, turn, creator)
select 'پایگاه داده',
       'دکتر زهره رسولی',
       'کلاس تست پایگاه داده',
       'salamdb',
       i.id,
       '1400',
       'spring',
       u.id
from "user" u,
     institute i
where u.firstname = 'زهره'
  and u.lastname = 'رسولی'
  and i.name = 'خواجه نصیرالدین طوسی';
end;

-- 3 --
insert into classparticipation(class, developer)
select 1, d.id
from "user" d
where concat(d.firstname, ' ', d.lastname) in ('الهام نیایشی', 'رضا ملکی', 'مرتضی مولایی', 'آرمان فدایی');

-- 4 --
insert into problemset(title, start, "end", type, class)
values ('تمرین اول', now(), now() + interval '7 days', 'practice', 1);

prepare insert_problem(integer, integer, varchar, text, integer, varchar)
    as insert into problem(number, problemset, title, text, score, category)
       values ($1, $2, $3, $4, $5, $6);
execute insert_problem(1, 1, 'سوال 1', 'سوال 1', 1, 'دانشگاهی');
execute insert_problem(2, 1, 'سوال 2', 'سوال 2', 1, 'دانشگاهی');
execute insert_problem(3, 1, 'سوال 3', 'سوال 3', 1, 'دانشگاهی');

insert into submit(problem, "user", time, status, uri, incontest, final)
select p.id,
       u.id,
       ps.start + random() * (ps."end" - ps.start),
       'received',
       concat(md5(random()::text), '.', 'zip'),
       true,
       true
from class c
         join problemset ps on c.id = ps.class
         join problem p on ps.id = p.problemset
         join classparticipation cp on c.id = cp.class
         join "user" u on cp.developer = u.id
where c.id = 1
  and u.id in (select developer from classparticipation where class = c.id limit 3);

update class set archived = true where id = 1;
update problemset set public = true where class = 1;

-- 5 --
execute insert_problem(null, null, 'سوال تکنولوژی 1', 'متن سوال تکنولوژی 1', 50, 'تکنولوژی');
execute insert_problem(null, null, 'سوال تکنولوژی 2', 'متن سوال تکنولوژی 2', 100, 'تکنولوژی');
execute insert_problem(null, null, 'سوال تکنولوژی 3', 'متن سوال تکنولوژی 3', 150, 'تکنولوژی');
execute insert_problem(null, null, 'سوال تکنولوژی 4', 'متن سوال تکنولوژی 4', 200, 'تکنولوژی');
execute insert_problem(null, null, 'سوال تکنولوژی 5', 'متن سوال تکنولوژی 5', 250, 'تکنولوژی');

prepare insert_submit(varchar, integer)
    as insert into submit(problem, "user", time, status, uri, score, incontest, final)
       select p.id,
              u.id,
              now() + random() * interval '10 day',
              'judged',
              concat(md5(random()::text), '.', 'py'),
              p.score,
              false,
              true
       from "user" u,
            problem p
       where concat(u.firstname, ' ', u.lastname) = $1
         and p.id in (select id from problem order by random() limit $2);

execute insert_submit('علی غلامی', 4);
execute insert_submit('سعید حجازی', 3);
execute insert_submit('محمد رهنما', 1);

create view top
as
select concat(u.firstname, ' ', u.lastname)                     as name,
       split_part(u.mail, '@', 1)                               as username,
       count(*)                                                 as count,
       sum(case when p.category = 'تکنولوژی' then 1 else 0 end) as count_tech,
       sum(case when p.category = 'دانشگاهی' then 1 else 0 end) as count_uni
from "user" u
         join submit s on u.id = s."user"
         join problem p on s.problem = p.id
where s.score = p.score
  and s.status = 'judged'
group by u.id;

select * from top order by count_tech desc limit 10;

-- 6 --
