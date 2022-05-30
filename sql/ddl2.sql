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
    add constraint companylink_pkey primary key (company, type);

alter table problem_tag
    drop column tag;
drop table problemtag;
alter table problem_tag
    add column tag varchar(20) not null default 'surrogate';
alter table problem_tag
    add constraint problem_tag_pkey primary key (problem, tag);

alter table class
    add column creator integer not null default 0;
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
    drop column field;
drop table field;
alter table company
    add column field varchar(20) not null default 'surrogate';

alter table class
    drop column semester;
drop table semester;
alter table class
    add column year integer not null default 0;
alter table class
    add column turn semesterturn not null default 'fall';

alter table company_advantage
    drop column advantage;
drop table advantage;
alter table company_advantage
    add column advantage varchar(50) not null default 'surrogate';

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

alter table problemsetparticipation
    rename to problemset_user;

alter table problem_extension
    drop constraint fk_problem_extension_extension;
drop table extension;

alter table problemset
    add column vip boolean;