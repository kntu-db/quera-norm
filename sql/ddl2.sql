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
    add column submit integer;
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

alter table companylink drop constraint companylink_pkey;
alter table companylink drop column linktype;
drop table linktype;
alter table companylink add column type varchar(20);
alter table companylink add constraint companylink_pkey primary key (company, type);
