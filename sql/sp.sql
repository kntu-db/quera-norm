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

-- 6 --
create function ActiveProfessors(X varchar, Y varchar, A integer)
    returns table
            (
                name varchar
            )
    language sql
as
$$
select concat(u.firstname, ' ', u.lastname)
from "user" u
         join submit s on u.id = s."user"
         join problem p on s.problem = p.id
where exists(select 1 from problem_tag where problem = p.id and tag = X)
  and exists(select 1
             from class
                      join institute i on class.institute = i.id
             where creator = u.id
               and not archived
               and i.name = Y)
  and s.status = 'judged'
  and s.score = p.score
group by u.id
order by count(distinct s.problem) desc
limit A;
$$;

select * from ActiveProfessors('تکنولوژی', 'خواجه نصیرالدین طوسی', 5);

-- 7 --
create function LookingForJob(A integer, B integer, C jobcooperation)
    returns float
    language sql as
$$
select avg((extract(days from (now() - u.birthdate)) / 365.25)::integer)
from "user" u
         join city ct on u.city = ct.id
where u.type = 'developer'
  and exists(select 1
             from demand d
                      join joboffer j on d.joboffer = j.id
                      join company co on j.company = co.id
             where d.developer = u.id
               and co.city = ct.id
               and j.cooperation = C
               and A <= co.size and co.size <= B);
$$;

select * from LookingForJob(1000, 2000, 'part_time');

-- 8 --
create function NumSolutions(X varchar)
    returns table
            (
                category varchar,
                num      integer
            )
    language sql
as
$$
select p.category,
       sum(case
               when X = 'حل شده' then case when s.score = p.score then 1 else 0 end
               else case when s.score < p.score then 1 else 0 end
           end)
from problem p
         left join submit s on p.id = s.problem
group by p.category;
$$;

select * from NumSolutions('حل شده');

-- 9 --
create function MostPopulatedClass(X varchar, Yturn semesterturn, Yyear integer)
    returns integer
    language sql as
$$
select max(count)
from (select count(u.id) as count
      from "user" u
               join classparticipation cp on u.id = cp.developer
               right join class c on cp.class = c.id
               join institute i on c.institute = i.id
      where c.turn = Yturn
        and c.year = Yyear
        and i.name = X
      group by c.id) t;
$$;

select * from MostPopulatedClass('امیر کبیر', 'fall', 1399);

-- 10 --
create function AllCompanies(Y varchar, X varchar) returns setof varchar
    language sql as
$$
select name
from company
where not exists(select 1
                 from demand d
                          join joboffer j on d.joboffer = j.id
                          join "user" u on d.developer = u.id
                          join institute i on u.institute = i.id
                          join city c on u.city = c.id
                 where j.company = company.id
                   and c.name = X
                   and i.name = Y);
$$;

select * from AllCompanies('تهران', 'قزوین');

-- 11 --
create function MostWantedJobs(X integer, A varchar, B varchar, C developerlevel) returns setof joboffer
    language sql as
$$
select j.*
from joboffer j
         left join demand d on j.id = d.joboffer
         left join company co on j.company = co.id
         left join joboffer_technology jt on j.id = jt.joboffer
         left join technology t on jt.technology = t.id
where t.title = B
  and co.name = A
  and j.level = C
group by j.id
order by count(d.developer) desc
limit X;
$$;

select * from MostWantedJobs(5,'دیجی کالا', 'C#', 'junior');

-- 12 --
create function NoCompetition(X varchar)
    returns table
            (
                name   varchar,
                family varchar
            )
    language sql
as
$$
select u.firstname, u.lastname
from "user" u
where not exists(select 1 from contest_user cu where cu."user" = u.id)
   or not exists(select 1
                 from classparticipation cp
                          join class c on cp.class = c.id
                          join institute i on c.institute = i.id
                 where cp.developer = u.id
                   and i.name <> X);
$$;

select * from NoCompetition('امیر کبیر');

-- 13 --
create function CompleteScores(A varchar) returns setof varchar
    language sql as
$$
select concat(u.firstname, ' ', u.lastname)
from class c
         join classparticipation cp on c.id = cp.class
         join "user" u on cp.developer = u.id
where c.title = A
  and u.id not in (select t.developer
                   from (select cp.developer as developer, p.id
                         from classparticipation cp
                                  join problemset ps on c.id = ps.class
                                  join problem p on ps.id = p.problemset
                         where cp.class = c.id
                         except
                         select s."user", s.problem
                         from submit s
                                  join problem p on s.problem = p.id
                         where s.incontest
                           and s.score = p.score) t);
$$;

select * from CompleteScores('ریاضیات گسسته');

-- 14 --