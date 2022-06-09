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
create function BestRecently(X integer, Y date)
    returns table
            (
                user_name    varchar,
                contest_name varchar,
                score        integer
            )
    language sql
as
$$
select concat(u.firstname, ' ', u.lastname), ps.title, sum(coalesce(s.score, 0))
from "user" u
         left join contest_user cu on u.id = cu."user"
         left join problemset ps on cu.problemset = ps.id
         left join problem p on ps.id = p.problemset
         left join submit s on u.id = s."user" and p.id = s.problem
where (s.final or s.final is null)
  and (s.incontest or incontest is null)
  and ps.vip
  and ps.start >= Y
group by u.id, ps.id
order by sum(coalesce(s.score, 0)) desc
limit X;
$$;

select * from BestRecently(5, (now() - interval '5 day')::date);
