create extension if not exists "pg_trgm";

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table public.listings (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null,
  summary text not null,
  body text not null,
  city text,
  region text,
  country text not null default 'United States',
  website_url text,
  image_url text,
  featured boolean not null default false,
  status text not null default 'draft' check (status in ('draft', 'published')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.listing_categories (
  listing_id uuid not null references public.listings (id) on delete cascade,
  category_id uuid not null references public.categories (id) on delete cascade,
  primary key (listing_id, category_id)
);

create index listings_status_idx on public.listings (status);
create index listings_featured_idx on public.listings (featured);
create index listings_slug_idx on public.listings (slug);
create index listings_title_trgm_idx on public.listings using gin (title gin_trgm_ops);
create index listings_summary_trgm_idx on public.listings using gin (summary gin_trgm_ops);

alter table public.categories enable row level security;
alter table public.listings enable row level security;
alter table public.listing_categories enable row level security;

create policy "categories_select_public" on public.categories for select using (true);

create policy "listings_select_published" on public.listings for select using (status = 'published');

create policy "listing_categories_select_public" on public.listing_categories for select using (
  exists (
    select 1
    from public.listings l
    where l.id = listing_id
      and l.status = 'published'
  )
);

insert into public.categories (slug, name, sort_order)
values
  ('longevity', 'Longevity & diagnostics', 1),
  ('mindfulness', 'Mindfulness & stress', 2),
  ('fitness', 'Movement & fitness', 3),
  ('nutrition', 'Nutrition & metabolic health', 4);

with
  c_long as (
    select id from public.categories where slug = 'longevity' limit 1
  ),
  c_mind as (
    select id from public.categories where slug = 'mindfulness' limit 1
  ),
  c_fit as (
    select id from public.categories where slug = 'fitness' limit 1
  ),
  c_nut as (
    select id from public.categories where slug = 'nutrition' limit 1
  ),
  ins as (
    insert into public.listings (
      slug,
      title,
      summary,
      body,
      city,
      region,
      country,
      website_url,
      image_url,
      featured,
      status
    )
    values
      (
        'summit-longevity-institute',
        'Summit Longevity Institute',
        'Clinic-led programs pairing advanced diagnostics with practical habit coaching in a mountain setting.',
        'Summit Longevity focuses on a measured baseline: labs, body composition, and recovery markers, then builds a week-long rhythm of training, sleep hygiene, and nutrition education. Groups stay small so clinicians can personalize intensity. Evenings emphasize unstructured recovery and light mobility. The goal is not peak performance on day one—it is a sustainable plan you can continue at home with clear guardrails.',
        'Aspen',
        'Colorado',
        'United States',
        null,
        'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?auto=format&fit=crop&w=1200&q=80',
        true,
        'published'
      ),
      (
        'harbor-reset-retreat',
        'Harbor Reset Retreat',
        'A waterfront retreat emphasizing nervous system regulation and sleep quality.',
        'Harbor Reset is structured around three daily anchors: guided breathwork, outdoor walking blocks, and a consistent lights-out cadence. Meals are simple, blood-sugar aware, and designed to reduce decision fatigue. The program includes daily office hours with a behavioral coach for planning your return week. It is a strong fit if you want calm structure without a clinical feel.',
        'Camden',
        'Maine',
        'United States',
        null,
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=80',
        false,
        'published'
      ),
      (
        'mesa-vitality-lab',
        'Mesa Vitality Lab',
        'Desert campus combining strength training blocks with recovery modalities and education.',
        'Mesa Vitality Lab blends coached strength sessions with sauna and cold exposure in a conservative, supervised format. Education modules cover protein intake, resistance training fundamentals, and how to read wearable trends without obsession. The tone is pragmatic: fewer hacks, more repeatable habits. Expect heat, early mornings, and a supportive cohort pace.',
        'Scottsdale',
        'Arizona',
        'United States',
        null,
        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=1200&q=80',
        true,
        'published'
      ),
      (
        'redwood-mindfulness-center',
        'Redwood Mindfulness Center',
        'Forest-adjacent intensive for attention training, gentle movement, and digital boundaries.',
        'Redwood Mindfulness Center keeps devices minimized and schedules generous whitespace between sessions. Teachers rotate between seated practice, mindful walking loops, and short lectures on attention mechanics. The physical space is uncluttered on purpose—fewer visual triggers, more room to notice habits. It is ideal if you want a reset without a heavy clinical itinerary.',
        'Santa Cruz',
        'California',
        'United States',
        null,
        'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=1200&q=80',
        false,
        'published'
      ),
      (
        'lakeside-metabolic-studio',
        'Lakeside Metabolic Studio',
        'Short stays focused on glucose stability, meal planning, and strength maintenance.',
        'Lakeside Metabolic Studio teaches a repeatable plate framework, grocery navigation, and how to pair carbohydrates with protein and fiber. You will lift light-to-moderate loads to preserve muscle while adjusting food timing. The team emphasizes gentle accountability: daily check-ins, not surveillance. Expect practical cooking demos and take-home templates.',
        'Burlington',
        'Vermont',
        'United States',
        null,
        'https://images.unsplash.com/photo-1490645935967-10de6ba17061?auto=format&fit=crop&w=1200&q=80',
        false,
        'published'
      ),
      (
        'prairie-performance-house',
        'Prairie Performance House',
        'Athletic retreat for experienced movers who want coaching audits and recovery planning.',
        'Prairie Performance House assumes you already train regularly. Coaches film key lifts, adjust technique, and help you choose sustainable weekly volume. Recovery blocks include guided mobility and optional massage. The cohort skews experienced; beginners may feel fast-paced. Evenings are quiet to protect sleep ahead of morning sessions.',
        'Boulder',
        'Colorado',
        'United States',
        null,
        'https://images.unsplash.com/photo-1571019614242-c5c5dee9f50b?auto=format&fit=crop&w=1200&q=80',
        false,
        'published'
      ),
      (
        'atlantic-clinical-week',
        'Atlantic Clinical Week',
        'Physician-led week with structured diagnostics review and lifestyle prescriptions.',
        'Atlantic Clinical Week is the most clinical option in this demo dataset. You will complete a structured intake, targeted testing where appropriate, and a consolidated review with time for questions. Lifestyle modules cover sleep, stress, and exercise as medicine. It is not emergency care; it is planning-heavy and documentation-forward so you leave with a clear summary.',
        'Portland',
        'Maine',
        'United States',
        null,
        'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&w=1200&q=80',
        true,
        'published'
      ),
      (
        'canyon-sleep-lab-retreat',
        'Canyon Sleep Lab Retreat',
        'Sleep-forward programming with dark rooms, light hygiene, and wind-down rituals.',
        'Canyon Sleep Lab Retreat schedules training earlier in the day and protects late evenings for downshifting. You will track a simple sleep diary, adjust caffeine timing, and practice a repeatable wind-down sequence. The environment is intentionally low stimulation—soft surfaces, warm light after sunset, and limited evening programming. A good fit if sleep is your primary bottleneck.',
        'Sedona',
        'Arizona',
        'United States',
        null,
        'https://images.unsplash.com/photo-1520256862855-398228c41684?auto=format&fit=crop&w=1200&q=80',
        false,
        'published'
      ),
      (
        'evergreen-resilience-camp',
        'Evergreen Resilience Camp',
        'Outdoor-forward week blending hiking volume, strength maintenance, and cold-water practice.',
        'Evergreen Resilience Camp builds endurance with guided hikes and keeps strength work short and consistent. Cold-water sessions are optional, coached, and conservative. Nutrition emphasizes hydration, electrolytes, and adequate fuel for long days outside. The staff prioritizes injury prevention and honest pacing—this is not a punishment camp.',
        'Leavenworth',
        'Washington',
        'United States',
        null,
        'https://images.unsplash.com/photo-1551632811-561732d1e306?auto=format&fit=crop&w=1200&q=80',
        false,
        'published'
      ),
      (
        'willow-nutrition-immersion',
        'Willow Nutrition Immersion',
        'Hands-on kitchen confidence for high-protein cooking and travel-friendly meals.',
        'Willow Nutrition Immersion is for people who know what to eat in theory but struggle in practice. You will batch cook, pack travel meals, and rehearse restaurant ordering scripts. The team covers label reading without fear-mongering and builds a weekly rhythm that survives busy seasons. Expect collaborative kitchens and clear portion frameworks.',
        'Austin',
        'Texas',
        'United States',
        null,
        'https://images.unsplash.com/photo-1556910103-1c02745aae4d?auto=format&fit=crop&w=1200&q=80',
        false,
        'published'
      )
    returning id, slug
  )
insert into public.listing_categories (listing_id, category_id)
select ins.id, c_long.id from ins cross join c_long where ins.slug in ('summit-longevity-institute', 'mesa-vitality-lab', 'atlantic-clinical-week', 'canyon-sleep-lab-retreat')
union all
select ins.id, c_mind.id from ins cross join c_mind where ins.slug in ('harbor-reset-retreat', 'redwood-mindfulness-center', 'canyon-sleep-lab-retreat')
union all
select ins.id, c_fit.id from ins cross join c_fit where ins.slug in ('mesa-vitality-lab', 'prairie-performance-house', 'evergreen-resilience-camp')
union all
select ins.id, c_nut.id from ins cross join c_nut where ins.slug in ('lakeside-metabolic-studio', 'willow-nutrition-immersion');
