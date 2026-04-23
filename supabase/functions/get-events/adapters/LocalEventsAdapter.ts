import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.7";
import { EventModel, IAdapter } from "../types.ts";

export class LocalEventsAdapter implements IAdapter {
  private supabaseUrl = Deno.env.get("SUPABASE_URL") || "";
  private supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") || "";
  private supabase = createClient(this.supabaseUrl, this.supabaseAnonKey);

  async fetchEvents(
    city: string,
    country: string,
    keyword: string = "",
    lat?: number,
    lng?: number
  ): Promise<EventModel[]> {
    try {
      let query = this.supabase
        .from("local_events")
        .select("*")
        .eq("country", (country || "PK").toUpperCase());

      if (city) {
        // Simple city match
        query = query.ilike("city", `%${city}%`);
      }

      if (keyword) {
        query = query.or(`title.ilike.%${keyword}%,description.ilike.%${keyword}%`);
      }

      // If we have coordinates, we could do a radius search, but for now 
      // we'll stick to city-based for local manual events unless city is empty
      // In a real app, you'd use PostGIS here.

      const { data, error } = await query.order("date", { ascending: true });

      if (error) {
        console.error("LocalEventsAdapter Supabase error:", error);
        return [];
      }

      if (!data) return [];

      return data.map((event: any): EventModel => ({
        id: event.id,
        title: event.title,
        description: event.description || "No description available",
        category: event.category,
        date: event.date,
        startTime: event.start_time || "12:00:00",
        endTime: event.end_time || "14:00:00",
        latitude: event.latitude,
        longitude: event.longitude,
        venue: event.venue,
        city: event.city,
        country: event.country,
        price: event.price,
        imageUrl: event.image_url || "",
        organizerId: "local",
        organizerName: event.organizer_name,
        attendeeCount: event.attendee_count || 0,
        created_at: event.created_at,
      }));
    } catch (error) {
      console.error("LocalEventsAdapter Exception:", error);
      return [];
    }
  }
}
