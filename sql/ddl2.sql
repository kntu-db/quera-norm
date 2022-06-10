-- SQL Dialect : PostgreSQL
-- Second version of schema
-- Cleaning

-- Submit should be entity
alter table submit_test
    drop constraint fk_submit_test_user;
alter table submit
    drop constraint submit_pkey;
alter table submit
    add column id serial primary key;
alter table submit_test
    drop constraint submit_test_pkey;
alter table submit_test
    drop column "user";
alter table submit_test
    drop column time;
alter table submit_test
    add column submit integer not null default 0;
alter table submit_test
    alter column submit drop default;
alter table submit_test
    add constraint fk_submit_test_submit foreign key (submit) references submit (id)
        on delete cascade;
alter table submit_test
    add constraint submit_test_pkey primary key (problem, number, submit);

alter table user_role
    drop constraint fk_user_role_role;
alter table user_role
    drop constraint user_role_pkey;
drop table role;
alter table user_role
    alter column role type varchar(20);
alter table user_role
    add constraint user_role_pkey primary key ("user", role);

alter table company
    drop column address;
drop table address;
alter table company
    add column address varchar(100);
alter table company
    add column city integer;
alter table company
    add constraint fk_company_city foreign key (city) references city (id);

alter table companylink
    drop constraint companylink_pkey;
alter table companylink
    drop column linktype;
drop table linktype;
alter table companylink
    add column type varchar(20) not null default 'surrogate';
alter table companylink
    alter column type drop default;
alter table companylink
    add constraint companylink_pkey primary key (company, type);

alter table problem_tag
    drop column tag;
drop table problemtag;
alter table problem_tag
    add column tag varchar(20) not null default 'surrogate';
alter table problem_tag
    alter column tag drop default;
alter table problem_tag
    add constraint problem_tag_pkey primary key (problem, tag);

alter table class
    add column creator integer not null default 0;
alter table class
    alter column creator drop default;
alter table class
    add constraint fk_class_creator foreign key (creator) references "user" (id);

alter table problemset
    add column public boolean not null default false;

alter table institute
    drop constraint fk_institute_user;
alter table institute
    add constraint fk_institute_user foreign key ("user") references "user" (id)
        on delete set null;
alter table user_role
    drop constraint fk_user_role_user;
alter table user_role
    add constraint fk_user_role_user foreign key ("user") references "user" (id)
        on delete cascade;
alter table problemsetparticipation
    drop constraint fk_problemsetparticipation_user;
alter table problemsetparticipation
    add constraint fk_problemsetparticipation_user foreign key ("user") references "user" (id)
        on delete cascade;
alter table submit
    drop constraint fk_submit_user;
alter table submit
    add constraint fk_submit_user foreign key ("user") references "user" (id)
        on delete cascade;
alter table company
    drop constraint fk_company_employer;
alter table company
    add constraint fk_company_employer foreign key (employer) references "user" (id)
        on delete cascade;
alter table demand
    drop constraint fk_demand_developer;
alter table demand
    add constraint fk_demand_developer foreign key (developer) references "user" (id)
        on delete cascade;
alter table classparticipation
    drop constraint fk_class_developer_developer;
alter table classparticipation
    add constraint fk_class_developer_developer foreign key (developer) references "user" (id)
        on delete cascade;

alter table "user"
    add column joinedAt timestamp not null default now();

alter table company
    drop column size;
drop table companysize;
alter table company
    add column size integer not null default 0;
alter table company
    alter column size drop default;

alter table company
    drop column field;
drop table field;
alter table company
    add column field varchar(20) not null default 'surrogate';
alter table company
    alter column field drop default;

alter table class
    drop column semester;
drop table semester;
alter table class
    add column year integer not null default 0;
alter table class
    alter column year drop default;
alter table class
    add column turn semesterturn not null default 'fall';
alter table class
    alter column turn drop default;

alter table company_advantage
    drop column advantage;
drop table advantage;
alter table company_advantage
    add column advantage varchar(50) not null default 'surrogate';
alter table company_advantage
    alter column advantage drop default;

alter table technology
    drop column category;
drop table technologycategory;
alter table technology
    add column category varchar(20);

alter table problem
    drop column category;
drop table problemcategory;
alter table problem
    add column category varchar(20) not null default 'surrogate';
alter table problem
    alter column category drop default;

alter table problemsetparticipation
    rename to contest_user;

alter table problem_extension
    drop constraint fk_problem_extension_extension;
drop table extension;

alter table problemset
    add column vip boolean;

alter table "user"
    drop column name;
alter table "user"
    add column firstName varchar(50) not null default 'surrogate';
alter table "user"
    alter column firstName drop default;
alter table "user"
    add column lastName varchar(50) not null default 'surrogate';
alter table "user"
    alter column lastName drop default;

alter table class
    add column publishAfterArchive boolean not null default false;

alter table institute
    alter column "user" drop not null;

alter table classparticipation
    alter column studentnumber drop not null;

alter table submit
    drop column solvetime;

alter table problem
    alter column number drop not null;
alter table problem
    alter column problemset drop not null;

alter table "user"
    alter column public drop default;
alter table "user"
    alter column public drop not null;

alter table company
    drop column title;

create type DemandStatus as enum ('pending', 'accepted', 'rejected', 'cancelled');
alter table demand
    add column status DemandStatus not null default 'pending';
alter table demand
    alter column status drop default;

alter table "user"
    add column birthdate date;

alter table city
    drop column state;
drop table state;
alter table city
    add column state varchar(255) not null default 'surrogate';
alter table city
    alter column state drop default;

alter table "user"
    rename column public to isPublic;