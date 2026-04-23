export interface EventModel {
  id: string;
  title: string;
  description: string;
  category: string;
  date: string;
  startTime: string;
  endTime: string;
  latitude: number;
  longitude: number;
  venue: string;
  city: string;
  country: string;
  price: number;
  imageUrl: string;
  organizerId: string;
  organizerName: string;
  attendeeCount: number;
  created_at: string;
}

export interface IAdapter {
  fetchEvents(city: string, country: string, keyword?: string, lat?: number, lng?: number): Promise<EventModel[]>;
}
