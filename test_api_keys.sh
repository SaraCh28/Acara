#!/bin/bash

# API Keys Configuration Test Script
# Tests all adapters and verifies configuration

echo "================================"
echo "API KEYS CONFIGURATION TEST"
echo "================================"
echo ""

# Load environment
if [ -f "./supabase/.env.local" ]; then
    export $(cat ./supabase/.env.local | grep -v '^#' | xargs)
    echo "✅ Loaded environment from supabase/.env.local"
else
    echo "❌ supabase/.env.local not found"
fi

echo ""
echo "--- Test 1: Environment Variables Check ---"
echo ""

# Test Ticketmaster
if [ -z "$TICKETMASTER_API_KEY" ]; then
    echo "❌ TICKETMASTER_API_KEY: NOT SET"
else
    echo "✅ TICKETMASTER_API_KEY: SET (${#TICKETMASTER_API_KEY} chars)"
fi

# Test Eventbrite
if [ -z "$EVENTBRITE_OAUTH_TOKEN" ]; then
    echo "❌ EVENTBRITE_OAUTH_TOKEN: NOT SET"
else
    echo "✅ EVENTBRITE_OAUTH_TOKEN: SET (${EVENTBRITE_OAUTH_TOKEN})"
fi

# Test Eventbrite User ID
if [ -z "$EVENTBRITE_USER_ID" ]; then
    echo "❌ EVENTBRITE_USER_ID: NOT SET"
else
    echo "✅ EVENTBRITE_USER_ID: SET (${#EVENTBRITE_USER_ID} chars)"
fi

# Test SeatGeek
if [ -z "$SEATGEEK_CLIENT_ID" ]; then
    echo "❌ SEATGEEK_CLIENT_ID: NOT SET"
else
    echo "✅ SEATGEEK_CLIENT_ID: SET (${#SEATGEEK_CLIENT_ID} chars)"
fi

# Test Google Places
if [ -z "$GOOGLE_PLACES_API_KEY" ]; then
    echo "❌ GOOGLE_PLACES_API_KEY: NOT SET"
else
    echo "✅ GOOGLE_PLACES_API_KEY: SET (${#GOOGLE_PLACES_API_KEY} chars)"
fi

echo ""
echo "--- Test 2: Supabase Configuration Check ---"
echo ""

SUPABASE_URL="https://cxfzgvlplnrqvtromazx.supabase.co"
SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN4ZnpndmxwbG5ycXZ0cm9tYXp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ0NTA4MTcsImV4cCI6MjA5MDAyNjgxN30.jcBhJNBA7Y5WehjgXWIVuivrRXU5AJcKiIZ87ioeUgU"

echo "✅ SUPABASE_URL: $SUPABASE_URL"
echo "✅ SUPABASE_ANON_KEY: Configured"

echo ""
echo "--- Test 3: API Connectivity Tests ---"
echo ""

# Test Eventbrite Token
echo "Testing Eventbrite token..."
if command -v curl &> /dev/null; then
    EVENTBRITE_RESPONSE=$(curl -s -H "Authorization: Bearer $EVENTBRITE_OAUTH_TOKEN" "https://www.eventbriteapi.com/v3/users/me/" -w "\n%{http_code}")
    HTTP_CODE=$(echo "$EVENTBRITE_RESPONSE" | tail -n 1)

    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ Eventbrite API: 200 OK (Token is VALID)"
    elif [ "$HTTP_CODE" = "401" ]; then
        echo "❌ Eventbrite API: 401 UNAUTHORIZED (Token is INVALID)"
    else
        echo "⚠️  Eventbrite API: $HTTP_CODE (Unexpected status)"
    fi
else
    echo "⚠️  curl not available, skipping Eventbrite test"
fi

# Test Ticketmaster (if key exists)
if [ -n "$TICKETMASTER_API_KEY" ]; then
    echo "Testing Ticketmaster API..."
    if command -v curl &> /dev/null; then
        TM_RESPONSE=$(curl -s "https://app.ticketmaster.com/discovery/v2/events.json?apikey=$TICKETMASTER_API_KEY&keyword=test&size=1" -w "\n%{http_code}" -o /tmp/tm_response.json)
        HTTP_CODE=$(tail -n 1 /tmp/tm_response.json)

        if [ "$HTTP_CODE" = "200" ]; then
            echo "✅ Ticketmaster API: 200 OK"
        else
            echo "❌ Ticketmaster API: $HTTP_CODE"
        fi
        rm -f /tmp/tm_response.json
    fi
else
    echo "❌ Ticketmaster API: Skipped (no API key)"
fi

# Test Supabase Connection
echo "Testing Supabase connection..."
if command -v curl &> /dev/null; then
    SUPABASE_RESPONSE=$(curl -s \
        -H "apikey: $SUPABASE_ANON_KEY" \
        -H "Content-Type: application/json" \
        "$SUPABASE_URL/rest/v1/local_events?limit=1" \
        -w "\n%{http_code}" \
        -o /tmp/sb_response.json)
    HTTP_CODE=$(tail -n 1 /tmp/sb_response.json)

    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ Supabase Connection: 200 OK"
        echo "   Checking local_events table..."

        # Count events in local_events
        EVENT_COUNT=$(curl -s \
            -H "apikey: $SUPABASE_ANON_KEY" \
            -H "Prefer: count=exact" \
            "$SUPABASE_URL/rest/v1/local_events?select=*&limit=0" \
            -I | grep -i "content-range" | awk '{print $2}' | cut -d'/' -f2)

        if [ -n "$EVENT_COUNT" ]; then
            echo "   ✅ local_events table has data: $EVENT_COUNT events"
        else
            echo "   ⚠️  local_events table: Unknown count or empty"
        fi
    else
        echo "❌ Supabase Connection: $HTTP_CODE"
    fi
    rm -f /tmp/sb_response.json
else
    echo "⚠️  curl not available, skipping Supabase test"
fi

echo ""
echo "================================"
echo "TEST SUMMARY"
echo "================================"
echo ""

CONFIG_STATUS=0
[ -n "$TICKETMASTER_API_KEY" ] && ((CONFIG_STATUS++))
[ -n "$EVENTBRITE_OAUTH_TOKEN" ] && ((CONFIG_STATUS++))
[ -n "$SEATGEEK_CLIENT_ID" ] && ((CONFIG_STATUS++))
[ -n "$GOOGLE_PLACES_API_KEY" ] && ((CONFIG_STATUS++))

echo "API Keys Configured: $CONFIG_STATUS/4"
echo ""
echo "Status:"
echo "  • Ticketmaster: $([ -n "$TICKETMASTER_API_KEY" ] && echo "✅ CONFIGURED" || echo "❌ MISSING")"
echo "  • Eventbrite: $([ -n "$EVENTBRITE_OAUTH_TOKEN" ] && echo "✅ CONFIGURED" || echo "❌ MISSING")"
echo "  • SeatGeek: $([ -n "$SEATGEEK_CLIENT_ID" ] && echo "✅ CONFIGURED" || echo "❌ MISSING")"
echo "  • Google Places: $([ -n "$GOOGLE_PLACES_API_KEY" ] && echo "✅ CONFIGURED" || echo "❌ MISSING")"
echo "  • Local Events: ✅ ALWAYS ENABLED"
echo ""

if [ "$CONFIG_STATUS" -lt 4 ]; then
    echo "⚠️  NOT ALL KEYS CONFIGURED"
    echo ""
    echo "Missing $(( 4 - CONFIG_STATUS )) API keys. App will only fetch from:"
    echo "  - Local Events (Supabase table)"
    [ -n "$EVENTBRITE_OAUTH_TOKEN" ] && echo "  - Eventbrite"
    echo ""
    echo "To configure missing keys, add them to: supabase/.env.local"
else
    echo "✅ ALL API KEYS CONFIGURED"
fi

echo ""

