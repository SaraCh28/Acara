import { EventModel, IAdapter } from "../types.ts";

export class GooglePlacesAdapter implements IAdapter {
  private apiKey = Deno.env.get("GOOGLE_PLACES_API_KEY") || "";

  async fetchEvents(city: string, country: string, keyword: string = "", lat?: number, lng?: number): Promise<EventModel[]> {
    if (!this.apiKey) return [];
    
    let url = `https://maps.googleapis.com/maps/api/place/textsearch/json?key=${this.apiKey}`;
    
    if (city) {
      url += `&query=events+in+${encodeURIComponent(city)}+${country}+${encodeURIComponent(keyword)}`;
    } else if (lat !== undefined && lng !== undefined) {
      url += `&query=events+in+${country}+${encodeURIComponent(keyword)}&location=${lat},${lng}&radius=50000`;
    } else {
      url += `&query=events+in+${country}+${encodeURIComponent(keyword)}`;
    }
    
    try {
      const response = await fetch(url);
      
      if (!response.ok) {
        const errorText = await response.text();
        console.error(`Google Places API error (${response.status}):`, errorText);
        return [];
      }

      const data = await response.json();
      
      if (!data.results || !Array.isArray(data.results)) {
        console.log("No results found in Google Places response.");
        return [];
      }
      
      return data.results.map((place: any): EventModel => ({
        id: place.place_id,
        title: place.name || "Local Event Site",
        description: place.formatted_address || "No description available",
        category: "Local Site",
        date: new Date().toISOString().split('T')[0], // Place search doesn't provide dates, using today
        startTime: "09:00:00",
        endTime: "18:00:00",
        latitude: place.geometry?.location?.lat || 0,
        longitude: place.geometry?.location?.lng || 0,
        venue: place.name || "Unknown Venue",
        city: city,
        country: country,
        price: 0,
        imageUrl: place.photos?.[0]?.photo_reference 
          ? `https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place.photos[0].photo_reference}&key=${this.apiKey}` 
          : "",
        organizerId: "google_places",
        organizerName: "Google Places",
        attendeeCount: 0,
        created_at: new Date().toISOString(),
      }));
    } catch (error) {
      console.error("GooglePlacesAdapter Exception:", error);
      return [];
    }
  }
}
