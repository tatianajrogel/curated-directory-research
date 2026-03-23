import { createSupabaseServerClient } from "@/lib/supabase/server";
import type { CategoryRow, ListingWithCategories } from "@/types/listing";

function ilikeOrPattern(term: string) {
  const safe = term
    .trim()
    .replace(/\\/g, "\\\\")
    .replace(/%/g, "\\%")
    .replace(/_/g, "\\_")
    .replace(/,/g, "");
  return `%${safe}%`;
}

export async function getCategories(): Promise<{
  ok: boolean;
  categories: CategoryRow[];
  error?: string;
}> {
  const supabase = await createSupabaseServerClient();
  if (!supabase) return { ok: false, categories: [], error: "missing_env" };

  const { data, error } = await supabase
    .from("categories")
    .select("id, slug, name, sort_order")
    .order("sort_order", { ascending: true });

  if (error) return { ok: false, categories: [], error: error.message };
  return { ok: true, categories: (data ?? []) as CategoryRow[] };
}

export async function getListings(options: {
  q?: string;
  categorySlug?: string;
}): Promise<{ ok: boolean; listings: ListingWithCategories[]; error?: string }> {
  const supabase = await createSupabaseServerClient();
  if (!supabase) return { ok: false, listings: [], error: "missing_env" };

  let listingIds: string[] | undefined;

  if (options.categorySlug) {
    const { data: cat, error: catError } = await supabase
      .from("categories")
      .select("id")
      .eq("slug", options.categorySlug)
      .maybeSingle();

    if (catError) return { ok: false, listings: [], error: catError.message };
    if (!cat) return { ok: true, listings: [] };

    const { data: junction, error: jError } = await supabase
      .from("listing_categories")
      .select("listing_id")
      .eq("category_id", cat.id);

    if (jError) return { ok: false, listings: [], error: jError.message };
    listingIds = (junction ?? []).map((row) => row.listing_id as string);
    if (listingIds.length === 0) return { ok: true, listings: [] };
  }

  let query = supabase
    .from("listings")
    .select(
      `
      id,
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
      status,
      created_at,
      updated_at,
      listing_categories (
        categories (
          id,
          slug,
          name,
          sort_order
        )
      )
    `,
    )
    .eq("status", "published")
    .order("featured", { ascending: false })
    .order("title", { ascending: true });

  if (listingIds) query = query.in("id", listingIds);

  const q = options.q?.trim();
  if (q) {
    const pattern = ilikeOrPattern(q);
    query = query.or(
      `title.ilike.${pattern},summary.ilike.${pattern}`,
    );
  }

  const { data, error } = await query;
  if (error) return { ok: false, listings: [], error: error.message };
  return { ok: true, listings: (data ?? []) as unknown as ListingWithCategories[] };
}

export async function getListingBySlug(
  slug: string,
): Promise<{ ok: boolean; listing: ListingWithCategories | null; error?: string }> {
  const supabase = await createSupabaseServerClient();
  if (!supabase) return { ok: false, listing: null, error: "missing_env" };

  const { data, error } = await supabase
    .from("listings")
    .select(
      `
      id,
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
      status,
      created_at,
      updated_at,
      listing_categories (
        categories (
          id,
          slug,
          name,
          sort_order
        )
      )
    `,
    )
    .eq("slug", slug)
    .eq("status", "published")
    .maybeSingle();

  if (error) return { ok: false, listing: null, error: error.message };
  return { ok: true, listing: data as unknown as ListingWithCategories | null };
}
