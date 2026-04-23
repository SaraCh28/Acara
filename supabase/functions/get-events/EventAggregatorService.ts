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

  private async _performSearch(city: string, country: string, keyword: string = "", lat?: number, lng?: number): Promise<EventModel[]> {
    let normalizedCountry = (country || "PK").toUpperCase();
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
    let allEvents: EventModel[] = [];

    try {
      // Priority 0: Local Manual Events (Always check these first for high-quality local results)
      console.log(`[LocalSource] Searching ${city}, ${country}...`);
      const localEvents = await this.localSource.fetchEvents(city, country, keyword, lat, lng);
      console.log(`[LocalSource] Found ${localEvents.length} events.`);
      if (localEvents.length > 0) allEvents = [...allEvents, ...localEvents];

      // Priority 1: Ticketmaster
      console.log(`[Ticketmaster] Searching ${city}, ${country}...`);
      const tmEvents = await this.ticketmaster.fetchEvents(city, country, keyword, lat, lng);
      console.log(`[Ticketmaster] Found ${tmEvents.length} events.`);
      if (tmEvents.length > 0) allEvents = [...allEvents, ...tmEvents];
      
      // Priority 2: Eventbrite
      console.log(`[Eventbrite] Searching ${city}, ${country}...`);
      const ebEvents = await this.eventbrite.fetchEvents(city, country, keyword, lat, lng);
      console.log(`[Eventbrite] Found ${ebEvents.length} events.`);
      if (ebEvents.length > 0) allEvents = [...allEvents, ...ebEvents];
      
      // Priority 3: SeatGeek
      console.log(`[SeatGeek] Searching ${city}, ${country}...`);
      const sgEvents = await this.seatgeek.fetchEvents(city, country, keyword, lat, lng);
      console.log(`[SeatGeek] Found ${sgEvents.length} events.`);
      if (sgEvents.length > 0) allEvents = [...allEvents, ...sgEvents];

      // Priority 4: Google Places (Useful for venues/local recurring events)
      console.log(`[GooglePlaces] Searching ${city}, ${country}...`);
      const gpEvents = await this.googlePlaces.fetchEvents(city, country, keyword, lat, lng);
      console.log(`[GooglePlaces] Found ${gpEvents.length} events.`);
      if (gpEvents.length > 0) allEvents = [...allEvents, ...gpEvents];

      return allEvents;
    } catch (error) {
      console.error("Aggregator _performSearch error:", error);
      return allEvents;
    }
  }
}
