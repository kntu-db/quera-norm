-- SQL Dialect : PostgreSQL
-- First version of schema

-- Authentication
create table State
(
    id   serial,
    name varchar(255) not null,
    primary key (id)
);

create table City
(
    id    serial,
    name  varchar(255) not null,
    state integer      not null,
    primary key (id)
);

alter table City
    add constraint FK_State_City foreign key (state) references State (id);

create type institutetype as enum
    (
        'university',
        'school',
        'institute'
        );

create table Institute
(
    id      serial,
    name    varchar(255)  not null,
    type    institutetype not null,
    city    integer       not null,
    website varchar(255),
    "user"  integer       not null,
    primary key (id)
);

alter table Institute
    add constraint FK_Institute_City foreign key (city) references City (id);

create type userstatus as enum
    (
        'active',
        'inactive',
        'not_verified'
        );

create type usertype as enum
    (
        'developer',
        'employer',
        'manager'
        );

-- because of sql is case-insensitive, we need to use lowercase
create table "user"
(
    id        serial,
    mail      varchar(255) not null,
    password  varchar(255) not null,
    name      varchar(255),
    status    userstatus   not null default 'not_verified',
    phone     varchar(255),
    type      usertype     not null,
    institute integer,
    city      integer,
    public    boolean      not null default true,
    primary key (id)
);

alter table "user"
    add constraint U_User_Mail unique (mail);
alter table "user"
    add constraint FK_User_Institute foreign key (institute) references Institute (id)
        on update cascade on delete set null;
alter table "user"
    add constraint FK_User_City foreign key (city) references City (id);
alter table Institute
    add constraint FK_Institute_User foreign key ("user") references "user" (id);

create table Role
(
    id    serial,
    title varchar(255) not null,
    primary key (id)
);

create table User_Role
(
    "user"     integer not null,
    role       integer not null,
    expiration timestamp,
    primary key ("user", role)
);

alter table User_Role
    add constraint FK_User_Role_User foreign key ("user") references "user" (id);
alter table User_Role
    add constraint FK_User_Role_Role foreign key (role) references Role (id)
        on delete cascade;
-- End of Authentication
-- ProblemSet
create type problemsettype as enum (
    'contest',
    'practice'
    );

create table ProblemSet
(
    id            serial,
    title         varchar(255)   not null,
    description   text,
    start         timestamp      not null,
    "end"         timestamp,
    visibleScores boolean        not null default true,
    visible       boolean        not null default true,
    type          problemsettype not null,
    class         integer,
    sponsor       varchar(255),
    primary key (id)
);

create table ProblemSetParticipation
(
    "user"     integer not null,
    problemSet integer not null,
    primary key ("user", problemSet)
);

alter table ProblemSetParticipation
    add constraint FK_ProblemSetParticipation_User foreign key ("user") references "user" (id);
alter table ProblemSetParticipation
    add constraint FK_ProblemSetParticipation_ProblemSet foreign key (problemSet) references ProblemSet (id)
        on delete cascade;

create table ProblemCategory
(
    id   serial,
    name varchar(255) not null,
    primary key (id)
);

create table ProblemTag
(
    id   serial,
    name varchar(255) not null,
    primary key (id)
);

create table Problem
(
    id         serial,
    number     integer      not null,
    problemSet integer      not null,
    title      varchar(255) not null,
    text       text         not null,
    score      integer      not null,
    category   integer,
    primary key (id)
);

alter table Problem
    add constraint FK_Problem_ProblemSet_Number_Unique unique (problemSet, number);
alter table Problem
    add constraint FK_Problem_ProblemSet foreign key (problemSet) references ProblemSet (id)
        on delete cascade;
alter table Problem
    add constraint FK_Problem_ProblemCategory foreign key (category) references ProblemCategory (id)
        on delete set null;

create table Problem_Tag
(
    problem integer not null,
    tag     integer not null,
    primary key (problem, tag)
);

alter table Problem_Tag
    add constraint FK_Problem_Tag_Problem foreign key (problem) references Problem (id)
        on delete cascade;
alter table Problem_Tag
    add constraint FK_Problem_Tag_Tag foreign key (tag) references ProblemTag (id)
        on delete cascade;

create table Extension
(
    extension varchar(16)  not null,
    name      varchar(255) not null,
    primary key (extension)
);

create table Problem_Extension
(
    problem     integer     not null,
    extension   varchar(16) not null,
    timeLimit   integer,
    memoryLimit integer,
    primary key (problem, extension)
);

alter table Problem_Extension
    add constraint FK_Problem_Extension_Problem foreign key (problem) references Problem (id)
        on delete cascade;
alter table Problem_Extension
    add constraint FK_Problem_Extension_Extension foreign key (extension) references Extension (extension)
        on update cascade;

create table Test
(
    number  integer      not null,
    problem integer      not null,
    title   varchar(255) not null,
    score   integer      not null,
    primary key (problem, number)
);

alter table Test
    add constraint FK_Test_Problem foreign key (problem) references Problem (id)
        on delete cascade;

create table IoTest
(
    number  integer not null,
    problem integer not null,
    input   text,
    output  text,
    primary key (problem, number)
);

alter table IoTest
    add constraint FK_IoTest_Problem foreign key (problem, number) references Test (problem, number)
        on delete cascade;

create table DockerizedTest
(
    number  integer      not null,
    problem integer      not null,
    image   varchar(255) not null,
    primary key (problem, number)
);

alter table DockerizedTest
    add constraint FK_DockerizedTest_Problem foreign key (problem, number) references Test (problem, number)
        on delete cascade;

create table WebTest
(
    number  integer      not null,
    problem integer      not null,
    package varchar(255) not null,
    primary key (problem, number)
);

alter table WebTest
    add constraint FK_WebTest_Problem foreign key (problem, number) references Test (problem, number)
        on delete cascade;

create type submitstatus as enum (
    'received',
    'queued',
    'running',
    'judged'
    );

create type submittype as enum
    (
        'git',
        'upload'
        );

create table Submit
(
    problem   integer      not null,
    "user"    integer      not null,
    time      timestamp    not null,
    solveTime integer      not null,
    status    submitstatus not null default 'queued',
    uri       varchar(255) not null,
    type      submittype   not null default 'upload',
    score     integer      not null default 0,
    inContest boolean      not null,
    final     boolean      not null,
    primary key (problem, "user", time)
);

alter table Submit
    add constraint FK_Submit_Problem foreign key (problem) references Problem (id)
        on delete cascade;
alter table Submit
    add constraint FK_Submit_User foreign key ("user") references "user" (id);

create type submitteststatus as enum
    (
        'wrong_answer',
        'compilation_error',
        'runtime_error',
        'time_limit_exceeded',
        'memory_limit_exceeded',
        'accepted'
        );

create table Submit_Test
(
    problem integer          not null,
    number  integer          not null,
    "user"  integer          not null,
    time    timestamp        not null,
    status  submitteststatus not null,
    primary key (problem, number, "user", time)
);

alter table Submit_Test
    add constraint FK_Submit_Test_Problem_Number foreign key (problem, number) references Test (problem, number)
        on delete cascade;
alter table Submit_Test
    add constraint FK_Submit_Test_User foreign key (problem, "user", time) references Submit (problem, "user", time)
        on delete cascade;
-- End of ProblemSet
-- Magnet
create table Field
(
    id    serial,
    title varchar(255) not null,
    primary key (id)
);

create table CompanySize
(
    id      serial,
    minSize int not null,
    maxSize int not null,
    primary key (id)
);

create table Advantage
(
    id    serial,
    title varchar(255) not null,
    primary key (id)
);

create table TechnologyCategory
(
    id    serial,
    title varchar(255) not null,
    primary key (id)
);

create table Technology
(
    id       serial,
    title    varchar(255) not null,
    category integer,
    primary key (id)
);

alter table Technology
    add constraint FK_Technology_Category foreign key (category) references TechnologyCategory (id)
        on delete set null;

create table Address
(
    id       serial,
    geoPoint point        not null,
    address  varchar(255) not null,
    city     integer      not null,
    primary key (id)
);

alter table Address
    add constraint FK_Address_City foreign key (city) references City (id);

create table Company
(
    id          serial,
    name        varchar(255) not null,
    foundedDate date,
    website     varchar(255),
    description text         not null,
    logo        varchar(255) not null,
    employer    integer      not null,
    address     integer      not null,
    title       varchar(255) not null,
    size        int          not null,
    field       integer      not null,
    primary key (id)
);

alter table Company
    add constraint FK_Company_Employer foreign key (employer) references "user" (id);
alter table Company
    add constraint FK_Company_Address foreign key (address) references Address (id);
alter table Company
    add constraint FK_Company_Field foreign key (field) references Field (id);
alter table Company
    add constraint FK_Company_Size foreign key (size) references CompanySize (id);

create table Company_Advantage
(
    company   integer not null,
    advantage integer not null,
    primary key (company, advantage)
);

alter table Company_Advantage
    add constraint FK_Company_Advantage_Company foreign key (company) references Company (id)
        on delete cascade;
alter table Company_Advantage
    add constraint FK_Company_Advantage_Advantage foreign key (advantage) references Advantage (id)
        on delete cascade;

create table Company_Technology
(
    company    integer not null,
    technology integer not null,
    primary key (company, technology)
);

alter table Company_Technology
    add constraint FK_Company_Technology_Company foreign key (company) references Company (id)
        on delete cascade;
alter table Company_Technology
    add constraint FK_Company_Technology_Technology foreign key (technology) references Technology (id);

create type developerlevel as enum
    (
        'intern',
        'junior',
        'middle',
        'senior',
        'lead'
        );

create type jobcooperation as enum
    (
        'part_time',
        'full_time'
        );

create table JobOffer
(
    id           serial,
    createdAt    timestamp,
    level        developerlevel not null,
    cooperation  jobcooperation not null,
    workDistance boolean        not null,
    salary       integer,
    title        varchar(255)   not null,
    company      integer        not null,
    city         integer        not null,
    description  text           not null,
    expired      boolean        not null default false,
    primary key (id)
);

alter table JobOffer
    add constraint FK_JobOffer_Company foreign key (company) references Company (id)
        on delete cascade;
alter table JobOffer
    add constraint FK_JobOffer_City foreign key (city) references City (id);

create table Demand
(
    developer   integer      not null,
    jobOffer    integer      not null,
    description varchar(255) not null,
    time        timestamp    not null,
    cvUri       varchar(255) not null,
    primary key (developer, jobOffer)
);

alter table Demand
    add constraint FK_Demand_Developer foreign key (developer) references "user" (id);
alter table Demand
    add constraint FK_Demand_JobOffer foreign key (jobOffer) references JobOffer (id)
        on delete cascade;

create table JobOffer_Technology
(
    jobOffer   integer not null,
    technology integer not null,
    primary key (jobOffer, technology)
);

alter table JobOffer_Technology
    add constraint FK_JobOffer_Technology_JobOffer foreign key (jobOffer) references JobOffer (id)
        on delete cascade;
alter table JobOffer_Technology
    add constraint FK_JobOffer_Technology_Technology foreign key (technology) references Technology (id);

create table LinkType
(
    id    serial,
    title varchar(255) not null,
    logo  varchar(255) not null,
    primary key (id)
);

create table CompanyLink
(
    linkType integer      not null,
    company  integer      not null,
    url      varchar(255) not null,
    primary key (linkType, company)
);

alter table CompanyLink
    add constraint FK_Link_LinkType foreign key (linkType) references LinkType (id)
        on delete cascade;
alter table CompanyLink
    add constraint FK_Link_Company foreign key (company) references Company (id)
        on delete cascade;
-- End of Magnet
-- Education
create type semesterturn as enum (
    'fall',
    'spring',
    'summer'
    );

create table Semester
(
    id   serial,
    turn semesterturn not null,
    year integer      not null,
    primary key (id)
);

create table Class
(
    id             serial,
    title          varchar(255) not null,
    professor      varchar(255) not null,
    description    varchar(255) not null,
    phone          integer,
    password       varchar(255) not null,
    maxCount       integer,
    archived       boolean      not null default false,
    openToRegister boolean      not null default true,
    semester       integer      not null,
    institute      integer      not null,
    primary key (id)
);

alter table Class
    add constraint FK_Class_Semester foreign key (semester) references Semester (id);
alter table Class
    add constraint FK_Class_Institute foreign key (institute) references Institute (id)
        on delete cascade;
alter table ProblemSet
    add constraint FK_ProblemSet_Class foreign key (class) references Class (id)
        on delete cascade;

create table ClassParticipation
(
    class         integer not null,
    developer     integer not null,
    studentNumber integer not null,
    primary key (class, developer)
);

alter table ClassParticipation
    add constraint FK_Class_Developer_Class foreign key (class) references Class (id)
        on delete cascade;
alter table ClassParticipation
    add constraint FK_Class_Developer_Developer foreign key (developer) references "user" (id);
-- End of Education