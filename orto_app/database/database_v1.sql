create extension if not exists pgcrypto;

create table if not exists gardens (
    id uuid primary key default gen_random_uuid(),

    name text not null,
    description text,

    latitude double precision not null,
    longitude double precision not null,

    beds_count integer not null default 0,

    bed_length_cm integer not null,
    bed_width_cm integer not null,
    path_width_cm integer not null,

    is_active boolean not null default true,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);
create table if not exists beds (

    id uuid primary key default gen_random_uuid(),

    garden_id uuid not null references gardens(id) on delete cascade,

    code text not null unique,

    number integer not null,

    name text not null,

    length_cm integer not null,

    width_cm integer not null,

    irrigation_zone integer,

    notes text,

    is_active boolean default true,

    created_at timestamptz default now(),
    updated_at timestamptz default now()
);
create table if not exists seasons (

    id uuid primary key default gen_random_uuid(),

    garden_id uuid not null references gardens(id) on delete cascade,

    year integer not null,

    name text not null,

    start_date date not null,
    end_date date,

    is_active boolean not null default false,

    notes text,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),

    constraint unique_garden_year unique(garden_id, year)
);