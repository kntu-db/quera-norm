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
insert into problemset(title, start, "end", type, sponsor, vip)
values ('دروغ 13', now() + interval '1 day', now() + interval '1 day 3 hours', 'contest', 'دیوار', true);

insert into problem(number, problemset, title, text, score, category)
values (1, 3, 'دروغ بزرگ', 'این یک دروغ است :)', 50, 'المپیاد'),
       (2, 3, 'دروغ متوسط', 'این یک دروغ است :)', 100, 'المپیاد'),
       (3, 3, 'دروغ کوچک', 'این یک دروغ است :)', 200, 'المپیاد');

prepare n_problem_for_contest(varchar, varchar, integer)
    as insert into submit(problem, "user", time, status, uri, score, incontest, final)
       select p.id,
              u.id,
              now() + random() * interval '10 day',
              'judged',
              concat('submit/', md5(random()::text), '.', 'java'),
              p.score,
              random()::int::boolean,
              true
       from "user" u,
            problem p
       where concat(u.firstname, ' ', u.lastname) = $1
         and p.id in (select p2.id
                      from problem p2
                               join problemset ps on p2.problemset = ps.id
                      where ps.title = $2
                      limit $3);

execute n_problem_for_contest('علی غلامی', 'دروغ 13', 3);
execute n_problem_for_contest('رضا ملکی', 'دروغ 13', 3);
execute n_problem_for_contest('زهره رسولی', 'دروغ 13', 1);

create function AverageNameQuestion(X varchar, Y varchar, C integer) returns float
    language sql as
$$
select avg(length(lastname))
from (select u.lastname as lastname
      from "user" u
               join submit s on u.id = s."user"
               join problem p on s.problem = p.id
               join problemset ps on p.problemset = ps.id
      where ps.title = X
        and p.category = Y
        and s.score = p.score
        and s.status = 'judged'
      group by u.id
      having count(s.problem) > C) t;
$$;

select * from AverageNameQuestion('دروغ 13', 'المپیاد', 2);

-- 4 --
insert into classparticipation (class, developer)
select 1, u.id
from "user" u
where u.mail = 'y.kamali@gmail.com';

create function compareSemester(t1 semesterturn, y1 integer, t2 semesterturn, y2 integer)
    returns integer
    language sql
as
$$
select case
           when y1 = y2 then
               case
                   when t1 = t2 then 0
                   when t1 > t2 then 1
                   else -1
                   end
           when y1 > y2 then 1
           else -1 end;
$$;

create function FavoriteStudent(A varchar, Xturn semesterturn, Xyear integer)
    returns setof "user"
    language sql
as
$$
select u.*
from "user" u
where exists(select 1
             from class c
                      join "user" p on c.creator = p.id
             where not c.archived
               and concat(p.firstname, ' ', p.lastname) = A
               and exists(select 1 from classparticipation cp where cp.class = c.id and cp.developer = u.id))
  and exists(select 1
             from class c
             where exists(select 1 from classparticipation cp where cp.class = c.id and cp.developer = u.id)
               and c.archived
               and compareSemester(c.turn, c.year, Xturn, Xyear) = 1);
$$;

select * from FavoriteStudent('علی غلامی', 'spring', 99);

-- 5 --
