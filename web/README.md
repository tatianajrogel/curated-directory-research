# Curated Retreats (Next.js + Supabase)

## Setup

1. Create a Supabase project.
2. **Create tables** (pick one):
   - **SQL Editor:** paste and run the full file [`../supabase/migrations/20260418120000_init.sql`](../supabase/migrations/20260418120000_init.sql), or
   - **From this folder:** add `DATABASE_URL` (full URI) **or** `SUPABASE_DB_PASSWORD` (only the DB password; host is derived from `NEXT_PUBLIC_SUPABASE_URL`) to `.env.local`, then run `npm run db:apply`.
3. Copy `.env.local.example` to `.env.local` and set `NEXT_PUBLIC_SUPABASE_URL` plus `NEXT_PUBLIC_SUPABASE_ANON_KEY` or `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY` from **Project Settings → API**.
4. Install and run:

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

### Why `DATABASE_URL` for `db:apply`

The public anon/publishable key cannot create tables. The `db:apply` script uses `psql` with your **database password** once to apply the migration file.

## Scripts

- `npm run dev` — development server
- `npm run build` — production build
- `npm run start` — serve production build
- `npm run lint` — ESLint
- `npm run db:apply` — apply all required Supabase migrations using `DATABASE_URL` in `.env.local`

## Notes

- Row Level Security allows **anonymous read** of published listings and categories only.
- Listing submissions are accepted through `POST /api/listing-submissions` and stored in `public.listing_submissions` for editorial review.
