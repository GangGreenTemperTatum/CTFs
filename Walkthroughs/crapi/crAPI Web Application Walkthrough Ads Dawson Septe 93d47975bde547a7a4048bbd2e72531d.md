# crAPI | Web Application | Walkthrough | Ads Dawson | September 2023

# 😇😇 **###### DISCLAIMER ######** *Spoilers below!* 😇😇

# [cRAPI (OWASP Project) Walkthrough](https://owasp.org/www-project-crapi/) `[CTF-ATHOME` Writeup](https://github.com/roottusk/vapi)

[@GangGreenTemperTatum](https://github.com/GangGreenTemperTatum)

[Postman Collection](https://www.postman.com/pynt-dev/workspace/goat-test/collection/24812707-1cb1eddf-f399-4f54-9f45-9892ed7d95f0) or local `openapi.json` [spec](https://github.com/levoai/demo-apps/blob/main/crAPI/api-specs/openapi.json)

[GitHub Repo](https://github.com/OWASP/crAPI)

**v1.0, 09-08-2023**

## Tips on amending Docker desktop to avoid paying for a license with replacement [Colima](https://github.com/abiosoft/colima) Container Runtime 🐳

- The process should go as following for MAC OS
1. Quit docker desktop
2. Run `docker image ls` → you should get an error like this `Cannot connect to the Docker daemon, ...`
3. Install colima → `brew install colima`
4. Start colima → `colima start --cpu 8 --memory 12` (cpu and memory options only need to be specified on the first run, they persist after that)
5. `docker context use colima`
6. Test the same `docker image ls` command. It shouldn’t error this time around
7. You can now run docker without Docker Desktop! Try building a container or running make dev

Follow up steps

1. Fully uninstall Docker Desktop:
2. Uninstall the docker desktop app from your Mac
3. Install the docker cli `brew install docker`
4. Edit `~/.docker/config.json` and remove the `credsStore` entry
5. `docker context use colima``
6. Install buildx and docker-compose

```
brew install docker-buildx docker-compose
mkdir -p ~/.docker/cli-plugins
ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
ln -sfn /opt/homebrew/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
```

## Setup your local crAPI environment: 🚘

[Docker setup](https://github.com/OWASP/crAPI)

Fix the `Error response from daemon: error while creating mount source path '/Users/adam/git/crapi/keys': chown /Users/<user>/git/crapi/keys: permission denied` error by running the `docker compose` command in `sudo`:

```markdown
docker pullcurl -o docker-compose.yml https://raw.githubusercontent.com/OWASP/crAPI/main/deploy/docker/docker-compose.yml
docker-compose pull
sudo docker-compose -f docker-compose.yml --compatibility up -d
```

To fix `dependency failed to start: container crapi-workshop is unhealthy`, do:

```markdown
sudo docker-compose -f docker-compose.yml pull
sudo docker-compose -f docker-compose.yml --compatibility up -d

docker ps -a
```

See [here](https://github.com/OWASP/crAPI/issues/156)

Access via [`http://localhost:8888/login`](http://localhost:8888/login) - Save this as your Postman `baseURl` variable

```markdown
[+] Running 8/8
 ✔ Container mongodb                      Healthy                                                                                                                                      0.0s
 ✔ Container api.mypremiumdealership.com  Running                                                                                                                                      0.0s
 ✔ Container postgresdb                   Healthy                                                                                                                                      0.0s
 ✔ Container mailhog                      Running                                                                                                                                      0.0s
 ✔ Container crapi-identity               Healthy                                                                                                                                      0.0s
 ✔ Container crapi-community              Healthy                                                                                                                                      0.0s
 ✔ Container crapi-workshop               Healthy                                                                                                                                      0.0s
 ✔ Container crapi-web                    Started
```

I recommend running the [setup commands](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d.md) a few times in succession to fix issues with unhealthy containers as part of the compose and is relating to networks failing/waiting to initiate and delays in the `docker-compose` build process.

Set your Burp Suite scope to ****Advanced**** and enter: (drop out of scope requests)

```markdown
Host: ^localhost\.*$
Port: ^8888$
File: ^/.*

Host: ^localhost\.*$
Port: ^8025$
File: ^/.*

etc.
```

I also recommend creating a new Postman `Environment` and linking variables from subsequent requests for a smoother experience.

To gracefully shutdown your local container environment:

```markdown
crapi % docker-compose down
```

📬 Access the mailbox at [http://localhost:8025/](http://localhost:8025/)

```markdown
Hi Hacking Crapi,

We are glad to have you on-board. Your newly purchased vehiche details are provided below. Please add it on your crAPI dashboard.

Your vehicle information is VIN: 7ZDCP26LKUH828122 and Pincode: 5339

We're here to help you build a relationship with your vehicles.

Thank You & have a wonderful day !
Warm Regards,
crAPI - Team
Email: support@crapi.io
  
This E-mail and any attachments are private, intended solely for the use of the addressee. If you are not the intended recipient, they have been sent to you in error: any use of information in them is strictly prohibited.
```

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled.png)

## crAPI Outlines the [Challenges](https://github.com/OWASP/crAPI/blob/develop/docs/challenges.md) within it’s Documentation Section 📚

# Challenges: 🔧

## BOLA Vulnerabilities - Flag 😈

### Challenge 1 - Access details of another user’s vehicle

Our initial REST API endpoint for `{{baseUrl}}/identity/api/v2/vehicle/vehicles` can be a pre-follow-up to `{{baseUrl}}/identity/api/v2/vehicle/:vehicleId/location`

Therefore, get the Vehicle ID from the initial `GET` request:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%201.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%202.png)

Setting the `uuid` was correct and is the `{{vehicleid}}` variable being used here in the next API endpoint which is the `carId` key value.

The `community` API endpoint is exposing this value from another API endpoint which we can use for our initial `GET` request here:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%203.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%204.png)

Sorry `"Robot"`..

### Challenge 2 - Access mechanic reports of other users

A fairly easy one, using hAPI path we can see a unique `report_link` exposed when we submit a test report:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%205.png)

I initially sent this request to Burp Repeater and tried to change the method from `POST` to `GET` but was unsuccessful.

Looking through the API swagger file, I found a Postman entry for `{{baseUrl}}/workshop/api/mechanic/mechanic_report?report_id=` endpoint, I simply enumerated the `report_id`to exploit this flag:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%206.png)

## Broken User Authentication - Flag 😈

### Challenge 3 - Reset the password of a different user

I found the REST API endpoint for `GET /community/api/v2/community/posts/` discloses sensitive information with another legitimate victim’s email address: (`robot001@example.com`)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%207.png)

Issued a `POST /identity/api/auth/forget-password` request and observed the results:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%208.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%209.png)

I now know that the OTP is a 4 decimal value from `0000` through `9999` and can use an enumeration attack.

Issue a request for our victim, intercept a live request and send to Burp Suite Intruder: (`POST /identity/api/auth/v3/check-otp HTTP/1.1`)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2010.png)

Add position payloads around the OTP value:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2011.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2012.png)

The failed response is a `500` HTTP server error code, which I can filter for any `200` responses or `!=500`

We can see ~30 requests results in a `503` response indicating we are being rate-limited (presumably by `srcip`). This is also not a HTTP header response from the codebase and therefore could be a proxy/WAF etc.

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2013.png)

Note the original untampered request is using API `v3`:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2014.png)

Maybe this was an enhancement and `v2` if live does not rate-limit?

Bingo! 👌

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2015.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2016.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2017.png)

Now with a Password Reset for our victim, we can successfully login and verify the JOT token is valid:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2018.png)

```markdown
jwt_tool master % python3 jwt_tool.py eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJyb2JvdDAwMUBleGFtcGxlLmNvbSIsInJvbGUiOiJwcmVkZWZpbmVkIiwiaWF0IjoxNjkzOTcxNjg1LCJleHAiOjE2OTQ1NzY0ODV9.gbLKqDbMbiCGZwIr5chKauNx51IlbXGLnczL0tjDx6q8tVHRiDZcMhUXtNAStg96pAuZogHdxyP5PzkBQio365no8HrsorrprgZAwp1CfC1-dykJdKV3MMbEMLQtO_ZrB50b85SEMZby1IPkit3QVAUgPw3vfb93jO0IxCRX3YRUc9yCc_o5ccG6f1jTuL7E2TpfUC_y9yzrtLBpl0QpW9tQpRmbYOgpUfJ151C4x-NH4tnDn8tE-aSNtVTeFcq8hzxh5RoVlz0y6CNfWm_yXcSDVDYE5y3M-hc8V2oK1NQ1dH1Tqq-xrM-nCFCWOGDLswTP2fFONaKNSfrQkFNRfA

        \   \        \         \          \                    \
   \__   |   |  \     |\__    __| \__    __|                    |
         |   |   \    |      |          |       \         \     |
         |        \   |      |          |    __  \     __  \    |
  \      |      _     |      |          |   |     |   |     |   |
   |     |     / \    |      |          |   |     |   |     |   |
\        |    /   \   |      |          |\        |\        |   |
 \______/ \__/     \__|   \__|      \__| \______/  \______/ \__|
 Version 2.2.6                \______|             @ticarpi

Original JWT:

=====================
Decoded Token Values:
=====================

Token header values:
[+] alg = "RS256"

Token payload values:
[+] sub = "robot001@example.com"
[+] role = "predefined"
[+] iat = 1693971685    ==> TIMESTAMP = 2023-09-05 20:41:25 (UTC)
[+] exp = 1694576485    ==> TIMESTAMP = 2023-09-12 20:41:25 (UTC)

Seen timestamps:
[*] iat was seen
[*] exp is later than iat by: 7 days, 0 hours, 0 mins

----------------------
JWT common timestamps:
iat = IssuedAt
exp = Expires
nbf = NotBefore
----------------------
```

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2019.png)

## Excessive Data Exposure - Flag 😈

### Challenge 4 - Find an API endpoint that leaks sensitive information of other users

Not sure what this exactly builds on from Challenge 3, but ultimately the same REST API endpoint is exposing excessive data about other users within the Community forum posts:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2020.png)

### Challenge 5 - Find an API endpoint that leaks an internal property of a video

I noticed an API endpoint `POST /identity/api/v2/user/videos HTTP/1.1` when submitting a video upload via `GET /my-profile HTTP/1.1` which provides an internal property of `conversion_params`:

```markdown
HTTP/1.1 200 
Server: openresty/1.17.8.2
Date: Thu, 07 Sep 2023 06:05:52 GMT
Content-Type: application/json
Connection: close
Vary: Origin
Vary: Access-Control-Request-Method
Vary: Access-Control-Request-Headers
Access-Control-Allow-Origin: *
X-Content-Type-Options: nosniff
X-XSS-Protection: 1; mode=block
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Pragma: no-cache
Expires: 0
X-Frame-Options: DENY
Content-Length: 8307609

{
  "id": 33,
  "video_name": "20201215_094957.mp4",
  "conversion_params": "-v codec h264",
  "profileVideo": "data:image/jpeg;base64,<BASE64ENCODEDSTRING=="
}
```

I am fairly certain this is the flag for this challenge.

## Rate Limiting - Flag 😈

### Challenge 6 - Perform a layer 7 DoS using ‘contact mechanic’ feature

When considering layer 7, this is the `HTTP` layer (`Application Layer` in OSI model) of the payload and as such has me thinking circumvention such as `X-Forwarded-By` HTTP headers, HTTP flooding techniques and botnet detections etc.

Analyzing the API endpoint requests to `POST /workshop/api/merchant/contact_mechanic HTTP/1.1`:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2021.png)

The `200` OK response is received regardless of whether the `X-Forwarded-For` headers are inserted within the Repeater here and the `report_id` integer value keeps incrementing.

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2022.png)

However, looking further I found the `json` blob key/value pairs were exploitable, leading to the DoS attack and flag:

```markdown
"repeat_request_if_failed":true,
"number_of_repeats":1000000000000000000000000000000000000000000
```

This makes sense, given that editing the HTTP (application-level AKA layer 7) payload is exploited to cause the DoS attack.

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2023.png)

## BFLA - Flag 😈

### Challenge 7 - Delete a video of another user

Looking at where we see our own video’s is REST API endpoint `GET /identity/api/v2/user/dashboard HTTP/1.1` which reveals a potential location clue:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2024.png)

We know we are looking for a `PUT` (update) or `POST` (create) request to `DELETE` (CRUD) a resource on the webserver. Pivoting to the Active Crawl (authenticated) I performed of the application and ordering by name shows some other potential pivots:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2025.png)

The JWT tokens in each payload are a bearer associated to my user account, but the `profileVideo` values are all unique (I.E different video paths for different users)

```markdown
Token payload values:
[+] sub = "hacker@example.com"
[+] role = "user"
[+] iat = 1694142238    ==> TIMESTAMP = 2023-09-07 20:03:58 (UTC)
[+] exp = 1694747038    ==> TIMESTAMP = 2023-09-14 20:03:58 (UTC)
```

The `profileVideo` values are base64-encoded values, which equate to the value inside the `WebKitFormBoundary` section:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2026.png)

Looking back on my old request, I can confirm my user `profileVideo` key/value is `BdajbPcE7i`: (so I want to delete a different one)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2027.png)

Attempting to send a `PUT` request to this API endpoint shows only `POST` requests are permitted:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2028.png)

I found a clue when looking at the API endpoint `/identity/api/v2/user/videos HTTP/1.1` from the crawl shows a `DELETE` request method is accepted:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2029.png)

I have an example name and ID from the prior crawl:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2030.png)

Therefore, change my Repeater request to:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2031.png)

Which gives away a huge clue:

```markdown
{"message":"This is an admin function. Try to access the admin API","status":403}
```

I then tried to use an alternate approach by replacing `user` for `admin` within the API endpoint request from `DELETE /identity/api/v2/user/videos/33 HTTP/1.1` to `DELETE /identity/api/v2/admin/videos/33 HTTP/1.1` which is successful!

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2032.png)

Admitting here that I am being lazy, but alternatively my go-to would be to use `SecLists` from Daniel M and `Feroxbuster` tool to enumerate and fuzz the API endpoint for potential path’s that may exist within the API that we can leverage.

A very talented and incredibly phenomenal [mentor](https://danaepp.com/how-to-find-access-control-issues-in-apis) of mine once said:

📣 

```markdown
”It’s good practice when you see an endpoint route representing a lower priv user to see if a high priv user may be an alternate route to similar functionality. So when you see user/customer/student/company etc, see if admin/owner/teacher etc endpoints may exist that represent the higher priv context.”
```

Anyway, it goes a little something like this:

```markdown
feroxbuster -u http://localhost:8888/identity/api/v2/ -w ./SecLists/Discovery/Web-Content/raft-medium-directories.txt -H Accept:application/json "Authorization: Bearer eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJoYWNrZXJAZXhhbXBsZS5jb20iLCJyb2xlIjoidXNlciIsImlhdCI6MTY5NDQwMTEzMywiZXhwIjoxNjk1MDA1OTMzfQ.FRvnO_rOsqJExjLzQ7srBiOp3nHsYgqMf_dXZy3a7NMRY-46COnH7JOX9xbKmosFfQUjkPhzrfTqkY03ZuBGYSW3fADkQ_1TmaRyQJx4Yn9HOqvSpiF67HS0Ddn9z88z5ObWY8jqxiDYLReFwLZJ1OFUqaYGCjWyI17H-a5XI4JiCeHjGVwMHOIibQ_0AHqnpn9kjMmk87bYpIYE0DjLejtemrxe0CW7iJsPQ8Fq2syWaIjx-H3skPEjpGJ-JnVDf5OIiBFqXa8xXySp9oK1ljTYh-ob3ZgE4ehyAG4KwrNA3o4VHKJ99tgkqKhPP9EhQATeA9wBXygyzHiGUBfppA" -m GET DELETE --proxy http://localhost:8080
```

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2033.png)

Another handy tool is the built-in Burp Suite BAPP extension for `HTTPHeaders` which in the HTTP History sends a HTTP `OPTIONS` request to request, analyze and return available HTTP request methods accepted by the endpoint which is another clue here:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2034.png)

## Mass Assignment - Flag 😈

### Challenge 8 - Get an item for free

By default, cRAPI gifts us with $100 bucks to go nuts. I sent a test order and inspected the API request and response:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2035.png)

Let’s initiate a random order return:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2036.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2037.png)

The `GET /workshop/api/shop/orders/all HTTP/1.1` now shows a different status for `?order_id=4` as `"status":"return pending"`:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2038.png)

If I inspect the specific order ID with a `GET` request, I see the status again:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2039.png)

Since I want to ********************************UPDATE******************************** the resource (going back to `CRUD OPERATIONS`) (`CREATE`, `READ`, `UPDATE`, `DELETE`), let’s see if a HTTP `PUT` method is accepted:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2040.png)

`200 OK` is our major clue here. Since the HTTP response headers from the server indicate `Content-Type`:`application/json` is accepted, let’s add a JSON body to this request:

```markdown
{
"quantity":"1",
"status":"test"
}
```

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2041.png)

The server response (`400`) gives us the answer here:

```markdown
{"message":"The value of 'status' has to be 'delivered','return pending' or 'returned'"}
```

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2042.png)

I changed the order status from `delivered` to `return pending`, then to `returned` but get a `500 Internal Server Error` and purely believe this to be related to my Docker environment as I noticed the `api-gateway`and `mongo:4.4` containers were regularly failing randomly:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2043.png)

### Challenge 9 - Increase your balance by $1,000 or more

The next challenge was one of my initial thoughts when exploiting challenge 8. What if I could place a large cost-based order, then amend this status to returned and would another function within the crAPI web app then issue me a credit/refund?

Let’s try buying 1000 wheels! `10 x 1000 = 10000` Inspect and send the `POST` request to the Burp Repeater to manipulate the quantity: (welp)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2044.png)

Checkout the available headers again when looking at the `GET` request for the order:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2045.png)

Easy as 🥧

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2046.png)

### Challenge 10 - Update internal video properties

Let’s go back to the original request “`/identity/api/v2/user/videos HTTP/1.1`". As long as we get the path correct, the web application is allowing `PUT` request’s with what looks like inadequate sanitization.

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2047.png)

Our latest video upload shows a valid ID of `34`:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2048.png)

Here, we can see a successful `PUT` request has updated the resouce:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2049.png)

## SSRF - Flag 😈

### Challenge 11 - Make crAPI send an HTTP call to "[www.google.com](https://github.com/OWASP/crAPI/blob/develop/docs/www.google.com)" and return the HTTP response.

From my experience, locating SSRF attack vectors can be difficult unless it’s obvious that the application's normal traffic involves request parameters containing full URLs. Trying to identify other scenario’s such as Partial URLs in requests, URLs within data formats or SSRF via the Referer header is more involved.

I first checked my Target Scope in Burp Suite for `3xx` (open-redirects) but left me empty handed:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2050.png)

Navigating through the UI, I decided to check out the `contact` feature and can see the API is making an internal request to the web app under the `mechanic_api` key:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2051.png)

This flag is to use `google.com`, but for sake of my walkthrough I want to use my Burp Suite Collaborator URL instead: (this is working and accepted)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2052.png)

Verification from the collaborator:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2053.png)

## NoSQL Injection - Flag 😈

### Challenge 12 - Find a way to get free coupons without knowing the coupon code.

[NoSQL](https://www.imperva.com/learn/application-security/nosql-injection/) (Not Only SQL) refers to database systems that use more flexible data formats and do not support Structured Query Language (SQL). **They typically store and manage data as key-value pairs, documents, or data graphs.** ← Here is our clue

[NoSQL](https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/07-Input_Validation_Testing/05.6-Testing_for_NoSQL_Injection) database calls are written in the application’s programming language, a custom API call, or formatted according to a common convention (such as `XML`, `JSON`, `LINQ`, etc).

crAPI has a coupon validation endpoint at `POST /community/api/v2/coupon/validate-coupon HTTP/1.1`. Let’s edit the current request to a QueryString to test for NoSQL Injection using the NoSQLi bAPP extension:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2054.png)

Our received response here shows that this endpoint is potentially vulnerable to NoSQLi:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2055.png)

Performing some testing with noSQLi payloads, I verified this looks to be a backend MongoDB. As such, I amended my request to:

```markdown
{"coupon_code":{
"$ne":"ads_coupon_codeeezzzz"}
}
```

The `$ne` is a MongoDB Comparison Query Operator. The query must be sent within enclosed `json` and key/value pair’s for what data is being queried (in this case, the `coupon_code` is being verified - Example: **`({'team': {$ne : "Mavs"}})`.** 

**A**s such this query is sent and interpreted as… “verify the coupon code is not `ads_coupon_codeeezzzz` (which we know is unsuccessful from the `500` error and as such an implicit other available coupon) which yields successful:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2056.png)

To be sure, I sent a request for the actual coupon legitimate value:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2057.png)

## SQL Injection - TODO

### Challenge 13 - Find a way to redeem a coupon that you have already claimed by modifying the database

If we try to again redeem the coupon code which we originally validated, we get an error:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2058.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2059.png)

Now, let’s try performing some iSQL attacks against this `coupon_code` value, our aim is to trick the DB into thinking that redeemed coupon `TRAC075` has not been redeemed.

Here, I opted to use `sqlmap` tool

```markdown
sqlmap-dev master % python3 sqlmap.py --url http://localhost:8888/workshop/api/shop/apply_coupon?coupon_code= --auth-type Basic --auth-cred hacker@example.com:HackingCrapi123! -v
```

——— **TODO———**

## Unauthenticated Access - Flag 😈

### Challenge 14 - Find an endpoint that does not perform authentication checks for a user.

AKA Broken Authentication, my first thought was to hunt for endpoints which may leak sensitive information such as PII. Therefore, from my experience with crAPI’s API, I started some hAPI path emulating user activity and started to observe the results:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2060.png)

As a path of interest, this was interestingly and the first API endpoint that I tested, I sent to Burp Repeater and stripped the JWT token to remove any kind of bearer authentication. This was successful and the API endpoint is being leaked without a requirement for token authentication:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2061.png)

This is also true only for the `GET` method as you can see when I tried to send a manipulated HTTP `PUT` request, emulating an order takeover:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2062.png)

This vulnerability is not limited to one endpoint, this is just one example.

## JWT Vulnerabilities - TODO

### Challenge 15 - Find a way to forge valid JWT Tokens

Instantly here, I pivot to using the good old JWT Tool

```markdown
jwt_tool master % python3 jwt_tool.py eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJoYWNrZXJAZXhhbXBsZS5jb20iLCJyb2xlIjoidXNlciIsImlhdCI6MTY5NDQwMTEzMywiZXhwIjoxNjk1MDA1OTMzfQ.FRvnO_rOsqJExjLzQ7srBiOp3nHsYgqMf_dXZy3a7NMRY-46COnH7JOX9xbKmosFfQUjkPhzrfTqkY03ZuBGYSW3fADkQ_1TmaRyQJx4Yn9HOqvSpiF67HS0Ddn9z88z5ObWY8jqxiDYLReFwLZJ1OFUqaYGCjWyI17H-a5XI4JiCeHjGVwMHOIibQ_0AHqnpn9kjMmk87bYpIYE0DjLejtemrxe0CW7iJsPQ8Fq2syWaIjx-H3skPEjpGJ-JnVDf5OIiBFqXa8xXySp9oK1ljTYh-ob3ZgE4ehyAG4KwrNA3o4VHKJ99tgkqKhPP9EhQATeA9wBXygyzHiGUBfppA
```

Looking at my output, the “JOT” token associates a `role` (**private claim**) with the bearer token (current value = “`user`”):

```markdown
Token payload values:
[+] sub = "hacker@example.com"
[+] role = "user"
[+] iat = 1694401133    ==> TIMESTAMP = 2023-09-10 19:58:53 (UTC)
[+] exp = 1695005933    ==> TIMESTAMP = 2023-09-17 19:58:53 (UTC)

```

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2063.png)

Using the `-T` parameter, let’s tamper with the values:

```markdown
jwt_tool master % python3 jwt_tool.py -T eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJoYWNrZXJAZXhhbXBsZS5jb20iLCJyb2xlIjoidXNlciIsImlhdCI6MTY5NDQwMTEzMywiZXhwIjoxNjk1MDA1OTMzfQ.FRvnO_rOsqJExjLzQ7srBiOp3nHsYgqMf_dXZy3a7NMRY-46COnH7JOX9xbKmosFfQUjkPhzrfTqkY03ZuBGYSW3fADkQ_1TmaRyQJx4Yn9HOqvSpiF67HS0Ddn9z88z5ObWY8jqxiDYLReFwLZJ1OFUqaYGCjWyI17H-a5XI4JiCeHjGVwMHOIibQ_0AHqnpn9kjMmk87bYpIYE0DjLejtemrxe0CW7iJsPQ8Fq2syWaIjx-H3skPEjpGJ-JnVDf5OIiBFqXa8xXySp9oK1ljTYh-ob3ZgE4ehyAG4KwrNA3o4VHKJ99tgkqKhPP9EhQATeA9wBXygyzHiGUBfppA
```

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2064.png)

My new JWT token is:

```markdown
eyJhbGciOiJSUzI1NiJ9.eyJzdWIiOiJoYWNrZXJAZXhhbXBsZS5jb20iLCJyb2xlIjoiYWRtaW4iLCJpYXQiOjE2OTQ0MDExMzMsImV4cCI6MTY5NTAwNTkzM30.FRvnO_rOsqJExjLzQ7srBiOp3nHsYgqMf_dXZy3a7NMRY-46COnH7JOX9xbKmosFfQUjkPhzrfTqkY03ZuBGYSW3fADkQ_1TmaRyQJx4Yn9HOqvSpiF67HS0Ddn9z88z5ObWY8jqxiDYLReFwLZJ1OFUqaYGCjWyI17H-a5XI4JiCeHjGVwMHOIibQ_0AHqnpn9kjMmk87bYpIYE0DjLejtemrxe0CW7iJsPQ8Fq2syWaIjx-H3skPEjpGJ-JnVDf5OIiBFqXa8xXySp9oK1ljTYh-ob3ZgE4ehyAG4KwrNA3o4VHKJ99tgkqKhPP9EhQATeA9wBXygyzHiGUBfppA
```

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2065.png)

Now we want to try and find an API endpoint which returns the “`role: <user`" etc. Let’s try the dashboard homepage `GET /identity/api/v2/user/dashboard HTTP/1.1`:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2066.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2067.png)

No 🎲, maybe we need to look at hitting another `admin`-esq endpoint. 

Interesting, our crawl audit of cRAPI has shown API endpoint `GET /.well-known/jwks.json HTTP/1.1` which exposes a `jwks` file:

```markdown
{ "keys": [ { "kty": "RSA", "e": "AQAB", "use": "sig", "kid": "MKMZkDenUfuDF2byYowDj7tW5Ox6XG4Y1THTEGScRg8", "alg": "RS256", "n": "sZKrGYja9S7BkO-waOcupoGY6BQjixJkg1Uitt278NbiCSnBRw5_cmfuWFFFPgRxabBZBJwJAujnQrlgTLXnRRItM9SRO884cEXn-s4Uc8qwk6pev63qb8no6aCVY0dFpthEGtOP-3KIJ2kx2i5HNzm8d7fG3ZswZrttDVbSSTy8UjPTOr4xVw1Yyh_GzGK9i_RYBWHftDsVfKrHcgGn1F_T6W0cgcnh4KFmbyOQ7dUy8Uc6Gu8JHeHJVt2vGcn50EDtUy2YN-UnZPjCSC7vYOfd5teUR_Bf4jg8GN6UnLbr_Et8HUnz9RFBLkPIf0NiY6iRjp9ooSDkml2OGql3ww" } ] }
```

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2068.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2069.png)

"The JSON Web Key Set (JWKS) is a set of keys containing the public keys used to verify any JSON Web Token (JWT) issued by the Authorization Server and signed using the RS256 **[signing algorithm](https://auth0.com/docs/get-started/applications/signing-algorithms)**.”

Again, the JWT Tool features a handy flag we can use here:

```markdown
-jw JWKSFILE, --jwksfile JWKSFILE
                        JSON Web Key Store for Asymmetric crypto
```

First, let’s save the `jwksfile` locally and interpret with `jq`:

```markdown
jwt_tool master % cat ./crapi-jwksfile.txt
{ "keys": [ { "kty": "RSA", "e": "AQAB", "use": "sig", "kid": "MKMZkDenUfuDF2byYowDj7tW5Ox6XG4Y1THTEGScRg8", "alg": "RS256", "n": "sZKrGYja9S7BkO-waOcupoGY6BQjixJkg1Uitt278NbiCSnBRw5_cmfuWFFFPgRxabBZBJwJAujnQrlgTLXnRRItM9SRO884cEXn-s4Uc8qwk6pev63qb8no6aCVY0dFpthEGtOP-3KIJ2kx2i5HNzm8d7fG3ZswZrttDVbSSTy8UjPTOr4xVw1Yyh_GzGK9i_RYBWHftDsVfKrHcgGn1F_T6W0cgcnh4KFmbyOQ7dUy8Uc6Gu8JHeHJVt2vGcn50EDtUy2YN-UnZPjCSC7vYOfd5teUR_Bf4jg8GN6UnLbr_Et8HUnz9RFBLkPIf0NiY6iRjp9ooSDkml2OGql3ww" } ] }
jwt_tool master % cat ./crapi-jwksfile.txt | jq >> ./crapi-jwksfile.txt
jwt_tool master % cat ./crapi-jwksfile.txt
{ "keys": [ { "kty": "RSA", "e": "AQAB", "use": "sig", "kid": "MKMZkDenUfuDF2byYowDj7tW5Ox6XG4Y1THTEGScRg8", "alg": "RS256", "n": "sZKrGYja9S7BkO-waOcupoGY6BQjixJkg1Uitt278NbiCSnBRw5_cmfuWFFFPgRxabBZBJwJAujnQrlgTLXnRRItM9SRO884cEXn-s4Uc8qwk6pev63qb8no6aCVY0dFpthEGtOP-3KIJ2kx2i5HNzm8d7fG3ZswZrttDVbSSTy8UjPTOr4xVw1Yyh_GzGK9i_RYBWHftDsVfKrHcgGn1F_T6W0cgcnh4KFmbyOQ7dUy8Uc6Gu8JHeHJVt2vGcn50EDtUy2YN-UnZPjCSC7vYOfd5teUR_Bf4jg8GN6UnLbr_Et8HUnz9RFBLkPIf0NiY6iRjp9ooSDkml2OGql3ww" } ] }
{
  "keys": [
    {
      "kty": "RSA",
      "e": "AQAB",
      "use": "sig",
      "kid": "MKMZkDenUfuDF2byYowDj7tW5Ox6XG4Y1THTEGScRg8",
      "alg": "RS256",
      "n": "sZKrGYja9S7BkO-waOcupoGY6BQjixJkg1Uitt278NbiCSnBRw5_cmfuWFFFPgRxabBZBJwJAujnQrlgTLXnRRItM9SRO884cEXn-s4Uc8qwk6pev63qb8no6aCVY0dFpthEGtOP-3KIJ2kx2i5HNzm8d7fG3ZswZrttDVbSSTy8UjPTOr4xVw1Yyh_GzGK9i_RYBWHftDsVfKrHcgGn1F_T6W0cgcnh4KFmbyOQ7dUy8Uc6Gu8JHeHJVt2vGcn50EDtUy2YN-UnZPjCSC7vYOfd5teUR_Bf4jg8GN6UnLbr_Et8HUnz9RFBLkPIf0NiY6iRjp9ooSDkml2OGql3ww"
    }
  ]
}
```

A very talented and incredibly phenomenal [mentor](https://danaepp.com/how-to-find-access-control-issues-in-apis) of mine curated [this fantastic (one of many) article](https://danaepp.com/how-to-use-azure-to-crack-api-auth-tokens) which really helped me go to the next level and achieve this flag!

Ultimately, we need to crack the existing JSON Web Token (JWT) captured from API traffic to recover the signing key to then forge our own valid token, which is what we are missing here.

My next move was to pivot to open-source Hashcat with a fresh untampered JWT which can cracking JWT’s signed with HS256, HS384, or HS512 algorithms:

——— **TODO———**

## << 2 secret challenges >> - 50% TODO

1. `POST` request to `/workshop/api/shop/products HTTP/1.1` for arbitrary products:

One strange thing I noticed during hAPI path from the `HTTP Headers` bAPP extension is that `/workshop/api/shop/products HTTP/1.1` endpoint allows the `POST` method. Let’s try abuse this!

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2070.png)

This seems to show that the application is allowing input for addition of products but requires a slightly different data format:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2071.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2072.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2073.png)

We could cause a bit more havoc here for fun with the Intruder:

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2074.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2075.png)

![Untitled](crAPI%20Web%20Application%20Walkthrough%20Ads%20Dawson%20Septe%2093d47975bde547a7a4048bbd2e72531d/Untitled%2076.png)

1. ——— **TODO———**