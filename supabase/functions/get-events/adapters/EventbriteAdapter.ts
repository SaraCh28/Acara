import { EventModel, IAdapter } from "../types.ts";

export class EventbriteAdapter implements IAdapter {
  private token = Deno.env.get("EVENTBRITE_OAUTH_TOKEN") || "";

  async fetchEvents(city: string, country: string, keyword: string = "", lat?: number, lng?: number): Promise<EventModel[]> {
    if (!this.token) return [];
    
    let url = `https://www.eventbriteapi.com/v3/events/search/?q=${keyword}&expand=venue,organizer`;
    
    if (city) {
      url += `&location.address=${encodeURIComponent(city)},${country}`;
    } else if (lat !== undefined && lng !== undefined) {
      url += `&location.latitude=${lat}&location.longitude=${lng}&location.within=100km`;
    }
    
    try {
      const response = await fetch(url, {
        headers: { "Authorization": `Bearer ${this.token}` }
      });
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error(`Eventbrite API error (${response.status}):`, errorText);
        return [];
      }

      const data = await response.json();
      
      if (!data.events || !Array.isArray(data.events)) {
        console.log("No events found in Eventbrite response.");
        return [];
      }
      
      return data.events.map((event: any): EventModel => ({
        id: event.id,
        title: event.name?.text || "Untitled Event",
        description: event.description?.text || "No description available",
        category: "Major Events",
        date: event.start?.local?.split('T')[0] || "",
        startTime: event.start?.local?.split('T')[1] || "00:00:00",
        endTime: event.end?.local?.split('T')[1] || "23:59:59",
        latitude: parseFloat(event.venue?.latitude || "0"),
        longitude: parseFloat(event.venue?.longitude || "0"),
        venue: event.venue?.name || "Unknown Venue",
        city: event.venue?.address?.city || city,
        country: event.venue?.address?.country || country,
        price: event.is_free ? 0 : 10.0, // Default price if not provided
        imageUrl: event.logo?.url || "",
        organizerId: event.organizer_id || "eventbrite",
        organizerName: event.organizer?.name || "Eventbrite Organizer",
        attendeeCount: event.capacity || 0,
        created_at: new Date().toISOString(),
      }));
    } catch (error) {
      console.error("EventbriteAdapter Exception:", error);
      return [];
    }
  }
}
