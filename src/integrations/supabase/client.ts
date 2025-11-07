// Updated client to handle HTTPS/HTTP mixed content issues
import { createClient } from '@supabase/supabase-js';
import type { Database } from './types';

const SUPABASE_URL = import.meta.env.VITE_SUPABASE_URL;
const SUPABASE_PUBLISHABLE_KEY = import.meta.env.VITE_SUPABASE_ANON_KEY;
const API_URL = import.meta.env.VITE_API_URL;
const USE_PROXY = import.meta.env.VITE_USE_PROXY === 'true';

// Check if we have mixed content issues (HTTPS site → HTTP Supabase)
const isMixedContentIssue = typeof window !== 'undefined' && 
  window.location.protocol === 'https:' && 
  SUPABASE_URL?.startsWith('http://');

let supabase: ReturnType<typeof createClient<Database>>;

if (USE_PROXY && isMixedContentIssue && API_URL) {
  // Create a custom client that proxies requests through Netlify Functions
  supabase = createClient<Database>(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
    auth: {
      storage: localStorage,
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true,
      flowType: 'pkce',
    },
    global: {
      headers: {
        'X-Client-Info': 'bimaided-portal',
      },
      fetch: async (url: string, options: any = {}) => {
        // Proxy data requests through Netlify Functions
        if (url.includes('/rest/v1/')) {
          console.log('Proxying request through Netlify Functions:', url);
          
          // Extract table and query parameters
          const urlObj = new URL(url);
          const pathParts = urlObj.pathname.split('/rest/v1/')[1];
          
          // For now, handle projects specifically
          if (pathParts?.startsWith('projects')) {
            const proxyUrl = `${API_URL}/supabase-proxy?action=projects`;
            return fetch(proxyUrl, {
              method: 'GET',
              headers: {
                'Content-Type': 'application/json',
              },
            });
          }
        }
        
        // For auth requests, proxy through auth handler
        if (url.includes('/auth/v1/')) {
          console.log('Proxying auth request through Netlify Functions');
          const proxyUrl = `${API_URL}/supabase-proxy?action=sign-in`;
          return fetch(proxyUrl, options);
        }
        
        // Fallback to direct request (may fail with mixed content)
        return fetch(url, options);
      },
    },
    db: {
      schema: 'public',
    },
    realtime: {
      params: {
        eventsPerSecond: 10,
      },
    },
  });
} else {
  // Normal Supabase client for local development or proper HTTPS setup
  supabase = createClient<Database>(SUPABASE_URL, SUPABASE_PUBLISHABLE_KEY, {
    auth: {
      storage: localStorage,
      persistSession: true,
      autoRefreshToken: true,
      detectSessionInUrl: true,
      flowType: 'pkce',
    },
    global: {
      headers: {
        'X-Client-Info': 'bimaided-portal',
      },
    },
    db: {
      schema: 'public',
    },
    realtime: {
      params: {
        eventsPerSecond: 10,
      },
    },
  });
}

export { supabase };