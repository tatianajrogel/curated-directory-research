alter table public.listing_submissions
  add constraint listing_submissions_business_name_length
    check (char_length(btrim(business_name)) between 2 and 120),
  add constraint listing_submissions_contact_name_length
    check (char_length(btrim(contact_name)) between 2 and 120),
  add constraint listing_submissions_contact_email_format
    check (
      char_length(btrim(contact_email)) between 5 and 160
      and contact_email ~* '^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$'
    ),
  add constraint listing_submissions_website_url_format
    check (
      website_url is null
      or website_url ~* '^https?://'
    ),
  add constraint listing_submissions_summary_length
    check (char_length(btrim(summary)) between 40 and 1200),
  add constraint listing_submissions_notes_length
    check (notes is null or char_length(notes) <= 2000);
