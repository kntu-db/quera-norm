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
