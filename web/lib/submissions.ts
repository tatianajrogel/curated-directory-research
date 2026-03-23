import type { CategoryRow } from "@/types/listing";

export type SubmissionFormValues = {
  businessName: string;
  contactName: string;
  contactEmail: string;
  websiteUrl: string;
  location: string;
  categorySlug: string;
  summary: string;
  notes: string;
  company: string;
};

export type SubmissionPayload = {
  business_name: string;
  contact_name: string;
  contact_email: string;
  website_url: string | null;
  location: string | null;
  category_slug: string | null;
  summary: string;
  notes: string | null;
};

export const initialSubmissionForm: SubmissionFormValues = {
  businessName: "",
  contactName: "",
  contactEmail: "",
  websiteUrl: "",
  location: "",
  categorySlug: "",
  summary: "",
  notes: "",
  company: "",
};

function clean(value: string) {
  return value.trim();
}

function normalizeUrl(value: string) {
  const trimmed = clean(value);
  if (!trimmed) return "";
  if (/^https?:\/\//i.test(trimmed)) return trimmed;
  return `https://${trimmed}`;
}

function isValidEmail(value: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value);
}

export function validateSubmission(
  values: SubmissionFormValues,
  categories: CategoryRow[],
): { ok: true; payload: SubmissionPayload } | { ok: false; message: string } {
  if (clean(values.company)) {
    return { ok: false, message: "We could not verify this submission." };
  }

  const businessName = clean(values.businessName);
  const contactName = clean(values.contactName);
  const contactEmail = clean(values.contactEmail).toLowerCase();
  const websiteUrl = normalizeUrl(values.websiteUrl);
  const location = clean(values.location);
  const categorySlug = clean(values.categorySlug);
  const summary = clean(values.summary);
  const notes = clean(values.notes);

  if (businessName.length < 2 || businessName.length > 120) {
    return { ok: false, message: "Business name must be between 2 and 120 characters." };
  }
  if (contactName.length < 2 || contactName.length > 120) {
    return { ok: false, message: "Contact name must be between 2 and 120 characters." };
  }
  if (!isValidEmail(contactEmail) || contactEmail.length > 160) {
    return { ok: false, message: "Enter a valid contact email." };
  }
  if (websiteUrl) {
    try {
      const url = new URL(websiteUrl);
      if (!["http:", "https:"].includes(url.protocol)) {
        return { ok: false, message: "Website must start with http:// or https://." };
      }
    } catch {
      return { ok: false, message: "Enter a valid website URL." };
    }
  }
  if (categorySlug && !categories.some((category) => category.slug === categorySlug)) {
    return { ok: false, message: "Select a valid category." };
  }
  if (summary.length < 40 || summary.length > 1200) {
    return { ok: false, message: "Summary must be between 40 and 1200 characters." };
  }
  if (notes.length > 2000) {
    return { ok: false, message: "Notes must be 2000 characters or fewer." };
  }

  return {
    ok: true,
    payload: {
      business_name: businessName,
      contact_name: contactName,
      contact_email: contactEmail,
      website_url: websiteUrl || null,
      location: location || null,
      category_slug: categorySlug || null,
      summary,
      notes: notes || null,
    },
  };
}
