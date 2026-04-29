import { EventModel } from "./types.ts";
import { TicketmasterAdapter } from "./adapters/TicketmasterAdapter.ts";
import { EventbriteAdapter } from "./adapters/EventbriteAdapter.ts";
import { GooglePlacesAdapter } from "./adapters/GooglePlacesAdapter.ts";
import { LocalEventsAdapter } from "./adapters/LocalEventsAdapter.ts";
import { SeatGeekAdapter } from "./adapters/SeatGeekAdapter.ts";

export class EventAggregatorService {
  private ticketmaster = new TicketmasterAdapter();
  private eventbrite = new EventbriteAdapter();
  private googlePlaces = new GooglePlacesAdapter();
  private localSource = new LocalEventsAdapter();
  private seatgeek = new SeatGeekAdapter();
  async getEvents(city: string, country: string, keyword: string = "", lat?: number, lng?: number): Promise<EventModel[]> {
    // Tier 1: Try specific city search
    let events = await this._performSearch(city, country, keyword, lat, lng);
    
    // Tier 2: Fallback to coordinate-based "nearby" search if no events found
    if (events.length === 0 && lat !== undefined && lng !== undefined) {
      console.log(`No events found for city: ${city}. Falling back to nearby search...`);
      // Passing an empty city name will signal adapters to use coordinates/radius directly
      events = await this._performSearch("", country, keyword, lat, lng);
    }

    return events;
  }


  private async _performSearch(city: string, countryCode: string, keyword: string = "", lat?: number, lng?: number): Promise<EventModel[]> {
    let normalizedCountry = (countryCode || "").toUpperCase();
    console.log(`[Aggregator] _performSearch: city="${city}", country="${normalizedCountry}", keyword="${keyword}", coords=${lat},${lng}`);
    let allEvents: EventModel[] = [];

    // Search with country code
    allEvents = await this._actuallyPerformSearch(city, normalizedCountry, keyword, lat, lng);

    // If 0 found and it wasn't a specific coordinate search, try without country code to catch mismatches
    if (allEvents.length === 0 && city) {
      console.log(`No events found with country code ${normalizedCountry}. Retrying globally...`);
      allEvents = await this._actuallyPerformSearch(city, "", keyword, lat, lng);
    }

    return allEvents;
  }

  private async _actuallyPerformSearch(city: string, country: string, keyword: string = "", lat?: number, lng?: number): Promise<EventModel[]> {
    const adapters = [
      { name: "Local", adapter: this.localSource },
      { name: "Ticketmaster", adapter: this.ticketmaster },
      { name: "Eventbrite", adapter: this.eventbrite },
      { name: "SeatGeek", adapter: this.seatgeek },
      { name: "GooglePlaces", adapter: this.googlePlaces },
    ];

    console.log(`[Aggregator] Starting parallel search for "${keyword}" in ${city || "nearby"}, ${country}...`);

    // Helper to wrap adapter call with a timeout
    const fetchWithTimeout = async (name: string, adapter: any) => {
      const timeout = 6000; // 6 seconds timeout per adapter
      const timer = new Promise<EventModel[]>((_, reject) => 
        setTimeout(() => reject(new Error(`${name} timed out`)), timeout)
      );
      
      try {
        const result = await Promise.race([
          adapter.fetchEvents(city, country, keyword, lat, lng),
          timer
        ]);
        console.log(`[${name}] Found ${(result as EventModel[]).length} events.`);
        return result as EventModel[];
      } catch (err: any) {
        console.error(`[${name}] Failed:`, err.message);
        return [];
      }
    };

    const results = await Promise.all(adapters.map(a => fetchWithTimeout(a.name, a.adapter)));
    
    // Flatten results and remove duplicates if any (by ID)
    const allEvents = results.flat();
    const uniqueEventsMap = new Map<string, EventModel>();
    
    for (const event of allEvents) {
      if (!uniqueEventsMap.has(event.id)) {
        uniqueEventsMap.set(event.id, event);
      }
    }

    const finalEvents = Array.from(uniqueEventsMap.values());
    console.log(`[Aggregator] Total unique events found: ${finalEvents.length}`);
    
    return finalEvents;
  }
}
