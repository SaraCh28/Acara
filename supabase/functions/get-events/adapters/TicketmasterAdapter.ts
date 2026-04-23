import { EventModel, IAdapter } from "../types.ts";

export class TicketmasterAdapter implements IAdapter {
  private apiKey = Deno.env.get("TICKETMASTER_API_KEY") || "";

  async fetchEvents(city: string, country: string, keyword: string = "", lat?: number, lng?: number): Promise<EventModel[]> {
    if (!this.apiKey) return [];
    
    let url = `https://app.ticketmaster.com/discovery/v2/events.json?apikey=${this.apiKey}&countryCode=${country}&keyword=${keyword}`;
    
    if (city) {
      url += `&city=${encodeURIComponent(city)}`;
    } else if (lat !== undefined && lng !== undefined) {
      url += `&latlong=${lat},${lng}&radius=100&unit=km`;
    }
    
    try {
      const response = await fetch(url);
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error(`Ticketmaster API error (${response.status}):`, errorText);
        return [];
      }

      const data = await response.json();
      
      if (!data._embedded || !data._embedded.events || !Array.isArray(data._embedded.events)) {
        console.log("No events found in Ticketmaster response.");
        return [];
      }
      
      return data._embedded.events.map((event: any): EventModel => ({
        id: event.id,
        title: event.name,
        description: event.info || event.description || "No description available",
        category: event.classifications?.[0]?.segment?.name || "General",
        date: event.dates.start.localDate,
        startTime: event.dates.start.localTime || "00:00:00",
        endTime: "23:59:59",
        latitude: parseFloat(event._embedded?.venues?.[0]?.location?.latitude || "0"),
        longitude: parseFloat(event._embedded?.venues?.[0]?.location?.longitude || "0"),
        venue: event._embedded?.venues?.[0]?.name || "Unknown Venue",
        city: event._embedded?.venues?.[0]?.city?.name || city,
        country: event._embedded?.venues?.[0]?.country?.countryCode || country,
        price: event.priceRanges?.[0]?.min || 0,
        imageUrl: event.images?.[0]?.url || "",
        organizerId: "ticketmaster",
        organizerName: "Ticketmaster",
        attendeeCount: 0,
        created_at: new Date().toISOString(),
      }));
    } catch (error) {
      console.error("TicketmasterAdapter Error:", error);
      return [];
    }
  }
}
