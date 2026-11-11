-- 0001_init.sql
-- 自動交換日記アプリ 初期スキーマ（設計書 4章「データ設計」に対応）
-- MVP: profiles, circles, circle_members, invites, entries, reactions
-- v1.1: point_ledger, decorations, user_decorations

-- =========================================================
-- テーブル
-- =========================================================

create table public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  display_name text not null check (char_length(display_name) between 1 and 20),
  avatar_path  text,
  created_at   timestamptz not null default now()
);

create table public.circles (
  id         uuid primary key default gen_random_uuid(),
  name       text check (char_length(name) <= 30),
  kind       text not null check (kind in ('pair', 'group')),
  created_by uuid not null references public.profiles(id),
  created_at timestamptz not null default now()
);

create table public.circle_members (
  circle_id      uuid not null references public.circles(id) on delete cascade,
  user_id        uuid not null references public.profiles(id) on delete cascade,
  role           text not null default 'member' check (role in ('owner', 'member')),
  -- グループごとの共有項目（F-05）。初期値はすべてオフ
  share_settings jsonb not null default '{"place": false, "photo": false, "steps": false, "music": false}',
  joined_at      timestamptz not null default now(),
  primary key (circle_id, user_id)
);

create table public.invites (
  id         uuid primary key default gen_random_uuid(),
  circle_id  uuid not null references public.circles(id) on delete cascade,
  code       text not null unique check (code ~ '^[A-Z0-9]{8}$'),
  created_by uuid not null references public.profiles(id),
  expires_at timestamptz not null default now() + interval '24 hours',
  used_by    uuid references public.profiles(id),
  used_at    timestamptz
);

create table public.entries (
  id          uuid primary key default gen_random_uuid(),
  circle_id   uuid not null references public.circles(id) on delete cascade,
  user_id     uuid not null references public.profiles(id) on delete cascade,
  entry_date  date not null,                 -- 午前4時区切りの「1日」
  title       text check (char_length(title) <= 20),
  comment     text check (char_length(comment) <= 140),
  summary     jsonb not null default '{}',   -- EntrySummary（ADR-004）
  photo_path  text,
  sent_at     timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  unique (circle_id, user_id, entry_date)
);
create index entries_circle_date_idx on public.entries (circle_id, entry_date desc);

create table public.reactions (
  id         uuid primary key default gen_random_uuid(),
  entry_id   uuid not null references public.entries(id) on delete cascade,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  stamp      text not null,
  created_at timestamptz not null default now(),
  unique (entry_id, user_id, stamp)
);

-- ---- v1.1: ポイントとデコ（ADR-009, ADR-010） ----

create table public.point_ledger (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  amount     int not null check (amount <> 0),
  reason     text not null check (reason in ('title', 'comment', 'reaction_received', 'exchange')),
  grant_key  text not null,   -- 例: title:2026-11-11 。二重付与を防ぐ
  created_at timestamptz not null default now(),
  unique (user_id, grant_key)
);

create table public.decorations (
  id    text primary key,
  kind  text not null check (kind in ('theme', 'stamp', 'frame')),
  name  text not null,
  price int not null check (price >= 0)
);

create table public.user_decorations (
  user_id       uuid not null references public.profiles(id) on delete cascade,
  decoration_id text not null references public.decorations(id),
  equipped      boolean not null default false,
  acquired_at   timestamptz not null default now(),
  primary key (user_id, decoration_id)
);

create view public.point_balances with (security_invoker = true) as
  select user_id, coalesce(sum(amount), 0)::int as balance
  from public.point_ledger
  group by user_id;

-- =========================================================
-- RLS（設計書 4章「アクセス制御」）
-- =========================================================

alter table public.profiles          enable row level security;
alter table public.circles           enable row level security;
alter table public.circle_members    enable row level security;
alter table public.invites           enable row level security;
alter table public.entries           enable row level security;
alter table public.reactions         enable row level security;
alter table public.point_ledger      enable row level security;
alter table public.decorations       enable row level security;
alter table public.user_decorations  enable row level security;

-- 自分がそのグループのメンバーか
create function public.is_member(cid uuid)
returns boolean
language sql stable security definer set search_path = public
as $$
  select exists (
    select 1 from public.circle_members
    where circle_id = cid and user_id = auth.uid()
  );
$$;

-- profiles: 自分と同じグループのメンバーが読める / 自分だけ書ける
create policy profiles_select on public.profiles for select using (
  id = auth.uid()
  or exists (
    select 1 from public.circle_members a
    join public.circle_members b on a.circle_id = b.circle_id
    where a.user_id = auth.uid() and b.user_id = profiles.id
  )
);
create policy profiles_insert on public.profiles for insert with check (id = auth.uid());
create policy profiles_update on public.profiles for update using (id = auth.uid());

-- circles / circle_members: メンバーだけ読める。作成・参加は関数経由
create policy circles_select on public.circles for select using (public.is_member(id));
create policy members_select on public.circle_members for select using (public.is_member(circle_id));
create policy members_update_own on public.circle_members for update
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- invites: 直接は読み書きしない（ポリシーなし = 拒否）

-- entries: メンバーが読める / 自分の行だけ書ける
create policy entries_select on public.entries for select using (public.is_member(circle_id));
create policy entries_insert on public.entries for insert
  with check (user_id = auth.uid() and public.is_member(circle_id));
create policy entries_update on public.entries for update
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- reactions
create policy reactions_select on public.reactions for select using (
  exists (select 1 from public.entries e where e.id = entry_id and public.is_member(e.circle_id))
);
create policy reactions_insert on public.reactions for insert with check (
  user_id = auth.uid()
  and exists (select 1 from public.entries e where e.id = entry_id and public.is_member(e.circle_id))
);
create policy reactions_delete on public.reactions for delete using (user_id = auth.uid());

-- point_ledger: 自分の行だけ読める。書き込みポリシーなし（トリガーと関数だけが書く）
create policy ledger_select on public.point_ledger for select using (user_id = auth.uid());

-- decorations: ログインした全員が読める
create policy decorations_select on public.decorations for select to authenticated using (true);

-- user_decorations: 自分の行だけ。着せ替えだけ自分で更新可
create policy user_deco_select on public.user_decorations for select using (user_id = auth.uid());
create policy user_deco_update on public.user_decorations for update
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- =========================================================
-- 関数（RPC）
-- =========================================================

-- グループ作成 + 作成者を owner として追加
create function public.create_circle(p_kind text, p_name text default null)
returns uuid
language plpgsql security definer set search_path = public
as $$
declare
  v_id uuid;
begin
  if (select count(*) from circle_members where user_id = auth.uid()) >= 5 then
    raise exception 'circle_limit_reached';
  end if;
  insert into circles (name, kind, created_by) values (p_name, p_kind, auth.uid())
    returning id into v_id;
  insert into circle_members (circle_id, user_id, role) values (v_id, auth.uid(), 'owner');
  return v_id;
end;
$$;

-- 招待コード発行（メンバーのみ）
create function public.create_invite(p_circle_id uuid)
returns text
language plpgsql security definer set search_path = public
as $$
declare
  v_code text;
begin
  if not is_member(p_circle_id) then
    raise exception 'not_a_member';
  end if;
  loop
    v_code := upper(substr(translate(encode(extensions.gen_random_bytes(8), 'base64'), '+/=', ''), 1, 8));
    exit when v_code ~ '^[A-Z0-9]{8}$'
          and not exists (select 1 from invites where code = v_code);
  end loop;
  insert into invites (circle_id, code, created_by) values (p_circle_id, v_code, auth.uid());
  return v_code;
end;
$$;

-- 招待を受ける（期限・使用済み・5人上限をチェック）
create function public.accept_invite(p_code text)
returns uuid
language plpgsql security definer set search_path = public
as $$
declare
  v_inv invites%rowtype;
begin
  select * into v_inv from invites where code = upper(p_code) for update;
  if not found or v_inv.used_by is not null or v_inv.expires_at < now() then
    raise exception 'invite_invalid';
  end if;
  if is_member(v_inv.circle_id) then
    raise exception 'already_member';
  end if;
  if (select count(*) from circle_members where circle_id = v_inv.circle_id) >= 5 then
    raise exception 'circle_full';
  end if;
  if (select count(*) from circle_members where user_id = auth.uid()) >= 5 then
    raise exception 'circle_limit_reached';
  end if;
  insert into circle_members (circle_id, user_id) values (v_inv.circle_id, auth.uid());
  update invites set used_by = auth.uid(), used_at = now() where id = v_inv.id;
  return v_inv.circle_id;
end;
$$;

-- デコ交換（残高チェック + マイナスの台帳行 + 所持追加を1トランザクションで）
create function public.exchange_decoration(p_decoration_id text)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  v_price int;
  v_balance int;
begin
  -- 同じユーザーの同時実行を直列化
  perform pg_advisory_xact_lock(hashtext(auth.uid()::text));

  select price into v_price from decorations where id = p_decoration_id;
  if not found then
    raise exception 'decoration_not_found';
  end if;
  if exists (select 1 from user_decorations where user_id = auth.uid() and decoration_id = p_decoration_id) then
    raise exception 'already_owned';
  end if;
  select coalesce(sum(amount), 0) into v_balance from point_ledger where user_id = auth.uid();
  if v_balance < v_price then
    raise exception 'insufficient_points';
  end if;
  if v_price > 0 then
    insert into point_ledger (user_id, amount, reason, grant_key)
      values (auth.uid(), -v_price, 'exchange', 'exchange:' || p_decoration_id);
  end if;
  insert into user_decorations (user_id, decoration_id) values (auth.uid(), p_decoration_id);
end;
$$;

-- =========================================================
-- トリガー（ポイント付与。F-12）
-- =========================================================

-- タイトル10pt / ひとこと5pt。grant_key が日付単位なので、グループが複数でも1日1回
create function public.grant_entry_points()
returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  if coalesce(new.title, '') <> '' then
    insert into point_ledger (user_id, amount, reason, grant_key)
      values (new.user_id, 10, 'title', 'title:' || new.entry_date)
      on conflict (user_id, grant_key) do nothing;
  end if;
  if coalesce(new.comment, '') <> '' then
    insert into point_ledger (user_id, amount, reason, grant_key)
      values (new.user_id, 5, 'comment', 'comment:' || new.entry_date)
      on conflict (user_id, grant_key) do nothing;
  end if;
  new.updated_at := now();
  return new;
end;
$$;

create trigger entries_grant_points
  before insert or update on public.entries
  for each row execute function public.grant_entry_points();

-- スタンプをもらったら日記の持ち主に2pt。自分へのスタンプは対象外。1日10ptまで
create function public.grant_reaction_points()
returns trigger
language plpgsql security definer set search_path = public
as $$
declare
  v_owner  uuid;
  v_today  date := (now() at time zone 'Asia/Tokyo')::date;
  v_earned int;
begin
  select user_id into v_owner from entries where id = new.entry_id;
  if v_owner is null or v_owner = new.user_id then
    return new;
  end if;
  select coalesce(sum(amount), 0) into v_earned
    from point_ledger
    where user_id = v_owner
      and reason = 'reaction_received'
      and (created_at at time zone 'Asia/Tokyo')::date = v_today;
  if v_earned < 10 then
    insert into point_ledger (user_id, amount, reason, grant_key)
      values (v_owner, 2, 'reaction_received', 'reaction:' || new.id)
      on conflict (user_id, grant_key) do nothing;
  end if;
  return new;
end;
$$;

create trigger reactions_grant_points
  after insert on public.reactions
  for each row execute function public.grant_reaction_points();

-- =========================================================
-- 権限: RPC はログインユーザーだけが呼べる
-- =========================================================
revoke execute on function public.create_circle(text, text)       from public, anon;
revoke execute on function public.create_invite(uuid)              from public, anon;
revoke execute on function public.accept_invite(text)              from public, anon;
revoke execute on function public.exchange_decoration(text)        from public, anon;
grant  execute on function public.create_circle(text, text)       to authenticated;
grant  execute on function public.create_invite(uuid)              to authenticated;
grant  execute on function public.accept_invite(text)              to authenticated;
grant  execute on function public.exchange_decoration(text)        to authenticated;

-- TODO(F-01): delete_account() は Storage の削除が絡むため Edge Function で実装する
