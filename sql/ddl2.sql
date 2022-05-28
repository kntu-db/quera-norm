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
