create table public.listing_submissions (
  id uuid primary key default gen_random_uuid(),
  business_name text not null,
  contact_name text not null,
  contact_email text not null,
  website_url text,
  location text,
  category_slug text,
  summary text not null,
  notes text,
  status text not null default 'pending' check (status in ('pending', 'reviewed', 'approved', 'rejected')),
  created_at timestamptz not null default now()
);

create index listing_submissions_status_idx on public.listing_submissions (status);
create index listing_submissions_created_at_idx on public.listing_submissions (created_at desc);

alter table public.listing_submissions enable row level security;

create policy "listing_submissions_insert_public"
on public.listing_submissions
for insert
to anon, authenticated
with check (status = 'pending');
