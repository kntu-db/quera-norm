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
begin;
insert into classparticipation(class, developer)
select 1, d.id
from "user" d
where concat(d.firstname, ' ', d.lastname) in ('الهام نیایشی', 'رضا ملکی', 'مرتضی مولایی', 'آرمان فدایی');
end;

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
       concat('submit/', md5(random()::text), '.', 'zip'),
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
              concat('submit/', md5(random()::text), '.', 'py'),
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
insert into "user"(firstname, lastname, mail, password, type, status)
values ('منابع انسانی', 'دیجی کالا', 'hr@digikala.com', '1234', 'employer', 'active');

insert into company(name, description, logo, employer, size, field)
select 'دیجی کالا', 'خرید آنلاین محصولات', 'logo/digikala.png', u.id, 1500, 'خرده فروشی'
from "user" u
where concat(u.firstname, ' ', u.lastname) = 'منابع انسانی دیجی کالا';

insert into problemset(title, start, "end", type, sponsor, vip)
values ('تحلیل داده', now() + interval '1 day', now() + interval '2 day', 'contest', 'دیجی کالا و اسنپ', true);

insert into contest_user ("user", problemset)
select u.id, ps.id
from "user" u,
     problemset ps
where ps.title = 'تحلیل داده'
  and concat(u.firstname, ' ', u.lastname)
    in ('محمد رهنما', 'آرمان فدایی', 'محمد سجادی', 'علی محمدی');

-- 7 --
insert into "user"(firstname, lastname, mail, password, type, status)
values ('منابع انسانی', 'اسنپ', 'hr@snapp.com', '1234', 'employer', 'active');

insert into company(name, description, logo, employer, size, field)
select 'اسنپ', 'تاکسی اینترنتی', 'logo/snapp.png', u.id, 2000, 'تاکسی اینترنتی'
from "user" u
where concat(u.firstname, ' ', u.lastname) = 'منابع انسانی اسنپ';

insert into "user"(firstname, lastname, mail, password, type, status)
values ('منابع انسانی', 'علی بابا', 'hr@alibaba.com', '1234', 'employer', 'active');

insert into company(name, description, logo, employer, size, field)
select 'علی بابا', 'بلیط', 'logo/alibaba.png', u.id, 1000, 'بلیط'
from "user" u
where concat(u.firstname, ' ', u.lastname) = 'منابع انسانی علی بابا';

prepare insert_joboffer(varchar, varchar, text) as
    insert into joboffer(level, cooperation, workdistance, title, company, city, description, createdat)
    select 'middle', 'full_time', false, $1, co.id, c.id, $3, now()
    from company co,
         city c
    where c.name = 'تهران'
      and co.name = $2;

execute insert_joboffer('برنامه نویس golang', 'اسنپ', 'به یک برنامه نویس باهوش نیازمندیم :)');
execute insert_joboffer('تحلیل گر داده', 'اسنپ', 'تحلیل گر داده');

execute insert_joboffer('برنامه نویس vuejs', 'علی بابا', 'برنامه نویس فرانت اند');
execute insert_joboffer('تحلیل گر داده', 'علی بابا', 'تحلیل گر داده');

-- 8 --
insert into demand(developer, joboffer, description, time, cvuri, status)
select u.id, j.id, 'اینجانب برنامه نویس با اراده', now(), concat('cv/', md5(random()::text), '.', 'pdf'), 'pending'
from "user" u,
     joboffer j
         join company c on j.company = c.id
where concat(u.firstname, ' ', u.lastname) = 'الهام نیایشی'
  and j.title = 'تحلیل گر داده'
  and c.name = 'اسنپ';

update demand set status = 'rejected'
where joboffer = (select id from joboffer where title = 'تحلیل گر داده' and company = (select id from company where name = 'اسنپ'))
and developer = (select id from "user" where concat(firstname, ' ', lastname) = 'الهام نیایشی');

-- Delete
delete
from "user" u
where u.joinedat < now() - interval '1 month'
  and not exists(select 1 from classparticipation cp where cp.developer = u.id)
  and not exists(select 1 from submit s where s."user" = u.id);

-- Insert
create table temp as
select
from company c
where exists(select 1
             from joboffer j
             where j.company = c.id
               and exists(select 1 from demand d where d.joboffer = j.id and d.status = 'accepted'));

-- View
create view Active40 as
select
from class c
         join classparticipation cp on c.id = cp.class
where c.archived = false
group by c.id
having count(cp.developer) >= 40;
