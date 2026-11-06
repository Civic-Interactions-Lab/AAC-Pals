drop table if exists public.room_words cascade;
drop table if exists public.beacons cascade;
drop table if exists public.rooms cascade;

alter table public.interaction_logs
    alter column room_id drop not null,
    alter column room_id type text using room_id::text;

alter table public.interaction_logs
    add column if not exists user_name     text,
    add column if not exists room_label    text,
    add column if not exists word_category text,
    add column if not exists board_section text check (board_section in ('main', 'room')),
    add column if not exists beacon_id     text,
    add column if not exists beacon_rssi   integer,
    add column if not exists device_id     text,
    add column if not exists device_name   text,
    add column if not exists device_model  text,
    add column if not exists os_version    text,
    add column if not exists app_version   text;

do $$
begin
    if not exists (
        select 1
        from pg_constraint c
        join pg_attribute a on a.attrelid = c.conrelid and a.attnum = any (c.conkey)
        where c.conrelid = 'public.interaction_logs'::regclass
          and c.contype = 'f'
          and a.attname = 'user_id'
    ) then
        alter table public.interaction_logs
            add constraint interaction_logs_user_id_fkey
            foreign key (user_id) references public.user_profiles (id) on delete cascade;
    end if;
end $$;

create index if not exists interaction_logs_admin_pressed_idx
    on public.interaction_logs (admin_id, pressed_at desc);

create index if not exists interaction_logs_user_pressed_idx
    on public.interaction_logs (user_id, pressed_at desc);

create index if not exists interaction_logs_device_idx
    on public.interaction_logs (device_id);
