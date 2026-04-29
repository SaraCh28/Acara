import { EventModel, IAdapter } from "../types.ts";

export class TicketmasterAdapter implements IAdapter {
  private apiKey = Deno.env.get("TICKETMASTER_API_KEY") || "";

  async fetchEvents(city: string, country: string, keyword: string = "", lat?: number, lng?: number): Promise<EventModel[]> {
    if (!this.apiKey) return [];
    
    let url = `https://app.ticketmaster.com/discovery/v2/events.json?apikey=${this.apiKey}&keyword=${encodeURIComponent(keyword)}`;
    
    if (country) {
      url += `&countryCode=${country}`;
    }

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
      
      return data._embedded.events.map((event: any): EventModel => {
        // Build a rich description from all available text fields
        const descParts: string[] = [];
        if (event.description) descParts.push(event.description);
        if (event.info) descParts.push(event.info);
        if (event.pleaseNote) descParts.push(`📌 Please note: ${event.pleaseNote}`);
        if (descParts.length === 0) {
          // Synthesize from classification + venue
          const segment = event.classifications?.[0]?.segment?.name || "";
          const genre = event.classifications?.[0]?.genre?.name || "";
          const venueName = event._embedded?.venues?.[0]?.name || "a local venue";
          const venueCity = event._embedded?.venues?.[0]?.city?.name || city;
          const genreStr = genre && genre !== "Undefined" ? ` ${genre}` : "";
          descParts.push(
            `${event.name} is ${segment ? `a ${segment}${genreStr} event` : "an exciting live event"} taking place at ${venueName} in ${venueCity}. Grab your tickets and join us for an unforgettable experience!`
          );
        }
        const description = descParts.join("\n\n");

        // Pick the best image (widest available)
        const images: any[] = event.images || [];
        const bestImage = images.sort((a: any, b: any) => (b.width || 0) - (a.width || 0))[0]?.url || "";

        return {
          id: `ticketmaster-${event.id}`,
          legacyId: event.id,
          sourceId: "ticketmaster",
          sourceName: "Ticketmaster",
          title: event.name,
          description,
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
          imageUrl: bestImage,
          organizerId: "ticketmaster",
          organizerName: event._embedded?.attractions?.[0]?.name || "Ticketmaster",
          attendeeCount: 0,
          created_at: new Date().toISOString(),
        };
      });
    } catch (error) {
      console.error("TicketmasterAdapter Error:", error);
      return [];
    }
  }
}
