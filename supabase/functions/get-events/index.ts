import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7";
import { EventAggregatorService } from "./EventAggregatorService.ts";

const aggregator = new EventAggregatorService();

// Supabase details for caching
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") || "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") || "";
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request) => {
  // Handle CORS Preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    let requestData: any = {};
    
    // Robust parsing: catch cases with no body or malformed JSON
    try {
      const text = await req.text();
      if (text) {
        requestData = JSON.parse(text);
      }
    } catch (e: any) {
      console.warn("Could not parse request body, using empty params:", e.message);
    }

    const city = requestData.city || "Lahore";
    const country = requestData.country || "PK";
    const keyword = requestData.keyword?.trim() || "";
    const lat = requestData.lat;
    const lng = requestData.lng;

    // 0. Diagnostics mode: Return a mock event if keyword is 'DIAGNOSE'
    if (keyword.toUpperCase() === "DIAGNOSE") {
      console.log("DIAGNOSE keyword detected. Returning test data.");
      
      const missingKeys = [];
      if (!Deno.env.get("TICKETMASTER_API_KEY")) missingKeys.push("TICKETMASTER_API_KEY");
      if (!Deno.env.get("EVENTBRITE_OAUTH_TOKEN")) missingKeys.push("EVENTBRITE_OAUTH_TOKEN");
      if (!Deno.env.get("GOOGLE_PLACES_API_KEY")) missingKeys.push("GOOGLE_PLACES_API_KEY");

      const diagnosticEvent = {
        id: "diag-123",
        title: "Diagnostic Test Event",
        description: missingKeys.length > 0 
          ? `SUCCESS: Pipeline is OK, but these API keys are MISSING: ${missingKeys.join(", ")}`
          : "SUCCESS: Pipeline and API keys are both CONFIGURED correctly.",
        category: "Diagnostics",
        date: new Date().toISOString().split("T")[0],
        startTime: "12:00:00",
        endTime: "13:00:00",
        latitude: lat || 0,
        longitude: lng || 0,
        venue: "Supabase Cloud",
        city: city,
        country: country,
        price: 0,
        imageUrl: "https://supabase.com/brand-assets/supabase-logo-icon.png",
        organizerId: "system",
        organizerName: "Acara Diagnostics",
        attendeeCount: 0,
        created_at: new Date().toISOString(),
      };
      
      return new Response(JSON.stringify([diagnosticEvent]), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 1. Check Cache (Supabase Table)
    const { data: cachedData, error: cacheError } = await supabase
      .from("cached_events")
      .select("data")
      .eq("city", city.toLowerCase())
      .eq("country", country.toUpperCase())
      .eq("keyword", keyword.toLowerCase())
      .gt("created_at", new Date(Date.now() - 30 * 60 * 1000).toISOString()) 
      .maybeSingle();

    if (cacheError) {
      console.error("Cache lookup error:", cacheError);
    }

    if (cachedData && req.headers.get("x-bypass-cache") !== "true") {
      console.log(`Cache hit for ${city}, ${country}, ${keyword}`);
      return new Response(JSON.stringify(cachedData.data), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    console.log(`Cache miss for ${city}, ${country}, ${keyword}. Fetching from APIs...`);

    // 2. Fetch from Aggregator
    const events = await aggregator.getEvents(city, country, keyword, lat, lng);

    // 3. Save to Cache (Async)
    if (events.length > 0) {
      edge_cache_events(city, country, keyword, events);
    }

    return new Response(JSON.stringify(events), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error: any) {
    console.error("Critical Function Error:", error);
    return new Response(
      JSON.stringify({ error: "Internal Server Error", details: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, "Content-Type": "application/json" } 
      }
    );
  }
});

async function edge_cache_events(city: string, country: string, keyword: string, events: any[]) {
  try {
    await supabase.from("cached_events").insert({
      city: city.toLowerCase(),
      country: country.toUpperCase(),
      keyword: keyword.toLowerCase(),
      data: events,
    });
  } catch (e) {
    console.error("Failed to cache events:", e);
  }
}
