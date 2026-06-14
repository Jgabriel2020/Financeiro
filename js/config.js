const SUPABASE_URL = 'https://mztjpwpsxxhfmozsugqc.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im16dGpwd3BzeHhoZm1venN1Z3FjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE0NTY2MzYsImV4cCI6MjA5NzAzMjYzNn0.tX0rCSDRGbSUK3ngNblj7nztP1GESH8zy_lgGySvMZs';

// Sobrescreve window.supabase (módulo CDN) com a instância do cliente
window.supabase = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
