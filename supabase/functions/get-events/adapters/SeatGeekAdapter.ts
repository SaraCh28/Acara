import { EventModel, IAdapter } from "../types.ts";

export class SeatGeekAdapter implements IAdapter {
  private clientId = Deno.env.get("SEATGEEK_CLIENT_ID") || "";

  async fetchEvents(
    city: string,
    country: string,
    keyword: string = "",
    lat?: number,
    lng?: number
  ): Promise<EventModel[]> {
    if (!this.clientId) return [];

    let url = `https://api.seatgeek.com/2/events?client_id=${this.clientId}&q=${encodeURIComponent(keyword)}&per_page=20`;

    if (city) {
      url += `&venue.city=${encodeURIComponent(city)}`;
    } else if (lat !== undefined && lng !== undefined) {
      url += `&lat=${lat}&lon=${lng}&range=100km`;
    }

    try {
      const response = await fetch(url);
      if (!response.ok) {
        console.error(`SeatGeek API error (${response.status})`);
        return [];
      }

      const data = await response.json();
      if (!data.events || !Array.isArray(data.events)) return [];

      return data.events.map((event: any): EventModel => ({
        id: `sg-${event.id}`,
        title: event.title,
        description: event.description || event.short_title || "No description available",
        category: event.type ? event.type.replace('_', ' ') : "General",
        date: event.datetime_local.split('T')[0],
        startTime: event.datetime_local.split('T')[1]?.split('.')[0] || "00:00:00",
        endTime: "23:59:59",
        latitude: event.venue?.location?.lat || 0,
        longitude: event.venue?.location?.lon || 0,
        venue: event.venue?.name || "Unknown Venue",
        city: event.venue?.city || city,
        country: event.venue?.country || country,
        price: event.stats?.lowest_price || 0,
        imageUrl: event.performers?.[0]?.image || "",
        organizerId: "seatgeek",
        organizerName: "SeatGeek",
        attendeeCount: 0,
        created_at: new Date().toISOString(),
      }));
    } catch (error) {
      console.error("SeatGeekAdapter Exception:", error);
      return [];
    }
  }
}
