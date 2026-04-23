class EnvConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://cxfzgvlplnrqvtromazx.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN4ZnpndmxwbG5ycXZ0cm9tYXp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0NTA4MTcsImV4cCI6MjA5MDAyNjgxN30.jcBhJNBA7Y5WehjgXWIVuivrRXU5AJcKiIZ87ioeUgU',
  );
}
