-- 1 --
create function NumClasses(A character)
    returns table
            (
                name        varchar,
                num_classes int
            )
    language sql
as
$$
select concat(u.firstname, ' ', u.lastname), count(c.class)
from "user" u
         left join classparticipation c on u.id = c.developer
where u.firstname like A || '%'
group by u.id
$$;

insert into class(title, professor, description, password, institute, year, turn, creator)
select 'میانی کامپیوتر',
       'علی غلامی',
       'کلاس درس علی',
       '123',
       i.id,
       '1400',
       'fall',
       u.id
from "user" u,
     institute i
where u.mail = 'ali@gmail.com'
  and i.name = 'خواجه نصیرالدین طوسی';

insert into "user" (firstname, lastname, mail, password, status, phone, type, public, joinedat)
values ('یلدا', 'کمالی', 'y.kamali@gmail.com', '1234', 'active', '09365648151', 'developer', true, now()),
       ('یگانه', 'محمودی', 'y.mahmoodi@gmail.com', '1234', 'active', '0990151510', 'developer', true, now());

insert into classparticipation (class, developer)
select c.id, u.id
from "user" u,
     class c
where u.mail = 'y.kamali@gmail.com'
  and c.title = 'میانی کامپیوتر';

select * from NumClasses('ی');

-- 2 --
create function NearDeadline(A integer, D integer)
    returns setof problem
    language sql
as
$$
select p.*
from problem p
         join problemset ps on p.problemset = ps.id
         join class c on ps.class = c.id
         join classparticipation cp on c.id = cp.class
where cp.developer = A
  and ps."end" is not null
  and ps."end" - now() < D * interval '1 days'
  and not exists(select 1 from submit s where s.problem = p.id and s."user" = A);
$$;

select * from NearDeadline(8, 5);

create function NearDeadline2(A integer, D integer)
    returns setof problemset
    language sql
as
$$
select ps.*
from problemset ps
         join class c on ps.class = c.id
where ps."end" is not null
  and ps."end" - now() < D * interval '1 days'
  and exists(select 1 from classparticipation cp where cp.class = c.id and cp.developer = A)
  and exists(select 1
             from problem p
             where p.problemset = ps.id
               and not exists(select 1 from submit s where s.problem = p.id and s."user" = A));
$$;

select * from NearDeadline2(8, 5);

-- 3 --
