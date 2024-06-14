create or replace function custom_headers()
returns void as $$
begin
    perform set_config('response.headers',
      '[{"Cache-Control": "public,s-maxage=86400"}]', false);

end; $$ language plpgsql;

