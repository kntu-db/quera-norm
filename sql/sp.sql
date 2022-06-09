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
