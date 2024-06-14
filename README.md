# HAProxy - PART II - Caching API with HAProxy

At Nexsol Technologies, we love **PostgreSQL** databases and **PostgREST** to expose APIs.

Let us explore optimizing PostgREST performance using HAProxy with HAProxy cache, as well as implementing security measures for the PostgREST API.

While the process is straightforward, it does require some expertise :-)

## Cookbook

### Security 

Take a look at this article on Medium : https://medium.com/@nexsol-tech/haproxy-part-i-secure-an-api-192604e8624c

### HAProxy cache

For security reasons, the HAProxy cache will never be used when the request contains an Authorization header.

Find here all the HAProxy cache limitations : https://docs.haproxy.org/2.9/configuration.html#6.1

HAProxy cache will not be used if PostgREST doesn't return a Cache-Control header. To achieved that, we need :
- A PostgreSQL function : custom_headers (see header.sql)
- PGRST_DB_PRE_REQUEST parameter (see docker-compose on demo-api service)

In this example, the Cache-Control header is set with this value : **public,s-maxage=86400**
Indicating a one-day maximum age for cached data.

HAProxy is configured to add an http header **X-Cache-Status**. It's value is 
- **MISS** if data is not present in the cache
- **HIT** if data is present in the cache

To be sure data is in the cache, just try this :
```
curl -XGET http://localhost:8091/postal?postalcode=eq.1227&order=common.asc --verbose
```

Then take a look at the headers returned by HAProxy (x-cache-status : HIT):
```
< HTTP/1.1 200 OK
< transfer-encoding: chunked
< date: Mon, 20 May 2024 06:30:31 GMT
< content-range: 0-8/*
< content-location: /aircrafts_data
< content-type: application/json; charset=utf-8
< age: 10
< x-cache-status: HIT
< content-security-policy: frame-ancestors 'none'
< x-content-type-options: nosniff
< x-frame-options: DENY
< cache-control: no-store
< strict-transport-security: max-age=16000000; includeSubDomains; preload;
```

## Performances benchmark

To mesure the performances, we used **bombardier** on a Apple Mac M1 - 8GB of memory.
100000 http requests and 125 clients

The database contains all the Swiss postal codes.

## Performances comparaison - with and without HAProxy

### On a small query returning 5 rows 
```
./bombardier -c 125 -n 100000 http://localhost:8091/postal?postalcode=eq.1227&order=common.asc
./bombardier -c 125 -n 100000 http://localhost:3000/postal?postalcode=eq.1227&order=common.asc
```

| Test | req/s | Ha proxy CPU % | Postgresql CPU % | Postgrestrest CPU % | Throughput | Test duration |
| -----| ----- | ------------ | ------ | ----- | ---- | --- |
| With HAProxy | 32179.23 | 120 | 0 | 0 | 41.47MB/s | 3 s |
| Without HAProxy | 4510.63 | 0 | 120 | 310 | 5.69MB/s | 22s | 

In this scenario it's about **7x faster** with HAProxy cache and it's using about **4x less CPU** during the test ...

### On a medium query returning all the cities of Geneva Canton.
```
./bombardier -c 125 -n 100000 http://localhost:8091/postal?canton\=eq.GE\&order\=common.asc
./bombardier -c 125 -n 100000 http://localhost:3000/postal\?canton\=eq.GE\&order\=common.asc
```

| Test | req/s | Ha proxy CPU % | Postgresql CPU % | Postgrestrest CPU % | Throughput | Test duration |
| -----| ----- | ------------ | ------ | ----- | ---- | --- |
| With HAProxy | 9210.26 | 80 | 0 | 0 | 190.07MB/s | 10 s |
| Without HAProxy | 1180 | 0 | 130 | 310 | 69.26MB/s | 2m24s | 

And in this case it's about **14x faster** with HAProxy cache and it's using about **6x less CPU** during the test ...

## Installation

You only need docker and docker-compose to install this demo.

Just run : 
 
```
bash start.sh
```

## Usage 

The PostgREST APIs are accessible on http://localhost:3000
The cached APIs are accessible on http://localhost:8091


## References

| HAProxy cache API | https://www.haproxy.com/blog/accelerate-your-apis-by-using-the-haproxy-cache |
| --------------- | ------------ |
| Bombardier | https://github.com/codesenberg/bombardier |
| PostgREST | https://postgrest.org/ |
| Demo Database | https://postgrespro.com/community/demodb |
| OWASP Security | https://cheatsheetseries.owasp.org/cheatsheets/REST_Security_Cheat_Sheet.html |

## One more thing

On haproxy.cfg file, at the backend section, you can add gzip compression like this :

```
backend www_backend
    mode             http
    compression algo gzip
    compression type application/json
```

You will see no overhead on HAProxy performances and you will have client side performance improvement.

