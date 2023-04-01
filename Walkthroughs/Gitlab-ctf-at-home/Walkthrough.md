# 😇😇 **###### DISCLAIMER ######** _Spoilers below!_ 😇😇
# [GitLab CTF `CTF-ATHOME` Writeup](https://about.gitlab.com/blog/2020/08/12/how-to-play-gitlab-ctf-at-home/)
[@GangGreenTemperTatum](https://github.com/GangGreenTemperTatum)
<br>
**v1.0, 03-31-2023**

![image](https://user-images.githubusercontent.com/104169244/229268224-78dce456-889f-40c0-9b05-ff89306732f7.png)

* This walkthrough does not explain the full concepts of the vulnerabilities used for exploits and assumes knowledge of the techniques as a pre-requisite to attempting the CTF.

## Additional Resources:
- Review or download the [**How to play GitLab's Capture the Flag at home** GitLab blog](https://about.gitlab.com/blog/2020/08/12/how-to-play-gitlab-ctf-at-home/)

## Setup Instructions:

- Ensure [Docker](https://www.docker.com/) is setup on your localhost
  > **Note**, from experience this lab will work in an isolated air-gapped environment but may fail when is comes to DNS requests
- I'd recommend ensuring you have a web proxy, [Postman](https://postman.com) and [Burp Suite](https://portswigger.net/) tools setup as tools, but additional internet access may help you with downloading tools from other repo's that you discover are needed during the challenges. 
- I'll be demonstrating my walkthrough using different examples and techniques of them all to mix it up.
  > **Note**, when using a tool such as Burp Suite to manipulate, proxy and send web requests to the application, you are most likely going to need to URL-encode the values sent (unless performed by default) as they would naturally when you emulate a user on the frontend [HAPPY-path](https://pwning.owasp-juice.shop/part1/happy-path.html#:~:text=Also%20known%20as%20the%20%22sunny,the%20user's%20or%20caller's%20goal.) regular browsing session or experience.

```
git clone https://gitlab.com/gitlab-com/gl-security/ctf-at-home.git
cd ctf-at-home
docker-compose up

# Once done, visit http://capture.local.thetanuki.io to get to the landing page
```

# Methodologies and Attack Vectors

## SSRF (Server Side Request Forgery)
### [Sea-Surf Challenge](http://capture.local.thetanuki.io/sea-surf) **1**:

* Sea-Surf challenges 1-3 are SSRF-based (Server Side Request Forgery).
- There are 3 different challenges, each with an increasing level of input url validation.
- I'll demonstrate these "easier" challenges in the browser by happy-path.

- SSRF-based attacks provide a follow-on mechanim(s) for further manipulation or exploits. However, ultimately in this lab our aim is to induce the server-side application to make requests to an unintended location.
- Let's try the server itself:

`http://127.0.0.1`

![image](https://user-images.githubusercontent.com/104169244/229268239-43aa0548-0006-4c19-b4df-e8b55a1245b6.png)

- From the error `Error: Head http://127.0.0.1: dial tcp 127.0.0.1:80: connect: connection refused`, its clear that the connectivity is permitted but on the wrong layer-4 TCP port.
- We could use a tool such as the [Burp Suite Intruder](https://portswigger.net/burp/documentation/desktop/tools/intruder#:~:text=Burp%20Intruder%20is%20a%20tool,into%20predefined%20positions%20each%20time.) to enumerate TCP ports 0-65535 as a spray of individual HTTP POST requests to identify the permitted port's if any.
- Another alternate approach could be to look for another commonly used HTTP port such as NGINX default:

`http://127.0.0.1:8080`

![image](https://user-images.githubusercontent.com/104169244/229268249-b7c416a4-6947-4a06-ad6e-b3a2e7e64a2f.png)

🙌 **Voila**!

* Right-click the page, `view page source` and haul your `X-Ctf-Flag` flag!

`[tanuki](9f433e5264fe2ce062a61b83d76001e1)`

![image](https://user-images.githubusercontent.com/104169244/229268256-035034c7-850a-4627-ae33-2a35ae763e80.png)

### [See-Surf Challenge](http://capture.local.thetanuki.io/sea-surf) **2**:

- Let's switch gears and try a redirect to the same localhost which we know is exploitable with SSRF via `http://127.0.0.1:8080` since as though our initial attempt from challenge 1 obviously fails.
- Searching for repo's such as [GitHub](https://github.com/search?q=ssrf+payloads) for "SSRF Payloads", or even a Google Dork for "SSRF to localhost redirect" returns a plethora of templates of payloads in which again we could use a tool like [Burp Suite Intruder](https://portswigger.net/burp/documentation/desktop/tools/intruder#:~:text=Burp%20Intruder%20is%20a%20tool,into%20predefined%20positions%20each%20time.) to enumerate a barrage of HTTP POST request's with unique SSRF redirect payloads, example from [Hahwul](https://www.hahwul.com/phoenix/ssrf-open-redirect/)'s fantastic cheatsheet:

`?url=http://127.0.0.1:8080`

<img width="1217" alt="image" src="https://user-images.githubusercontent.com/104169244/229268317-8236f3d3-38ff-4785-8ef5-e8befa8cb2d9.png">

- No dice.. and `Error: invalid url format` (using either IPv4 loopback or FQDN of `localhost` as well as the FQDN itself `ssrf2.local.thetanuki.io`) tells us that input validation coded into the web application is preventing this connection.
- How about using an external redirect service you say?

![image](https://user-images.githubusercontent.com/104169244/229268341-6835bdbc-ff3d-49ae-8847-ac6528a070fd.png)

* There are a few tools we could use to manipulate, create and validate our own external redirect service with one popular option to mention is [NGROK](https://ngrok.com/).
   - Here's a great follow-up blog on [Ngrok for Penetration Tester’s](https://medium.com/geekculture/ngrok-for-penetration-testers-78761ba0d02) that explains on how to build a service or listener.
   - I'd recommend [FRP](https://github.com/fatedier/frp) as a base project if your looking for something open-source and could even create an immutable template from in your own cloud infrastructure for an on-demand, self-managed approach which you can also boster with your own additional security controls.
> **Note**, all network requests (and sometimes more) for commercialized tools are normally logged. **You should never be without consent or a clear agreement to engage**.

- An easy approach would be to use a service such as [bit.ly](https://bitly.com/), [Tinyurl](https://tinyurl.com) or other external redirect service that we can use to create a URL shortener that ultimately points to localhost.
- Bitly won't let us specify `localhost` here, but will accept IPv4 addresses which we can use to represent 
  - Note, the generated shorted URL will be unique each time.

`https://bit.ly/3KoYCo4`

![image](https://user-images.githubusercontent.com/104169244/229268292-ef407ff5-5e86-4fad-aaa5-c8e01ec5abaf.png)

![image](https://user-images.githubusercontent.com/104169244/229268591-d85718fe-298a-4f20-a0bf-8a6f6eb981f7.png)

🙌 **Voila**!

* Right-click the page, `view page source` and haul your `X-Ctf-Flag` flag!

`[tanuki](befc98f16f2c5eae327472d4a996e017)`

![image](https://user-images.githubusercontent.com/104169244/229268597-116ed82b-9a8f-4378-a6ac-d54429a0aaa3.png)

### [Si-Surf Challenge](http://capture.local.thetanuki.io/sea-surf) **3**:

- Building on our knowledge and experience gained from challenges 1 and 2 as well as mulling some initial hypothesises, I looked into a DNS rebinding attack to circumvent what seems to show the web application's working input sanitization of the `url` parameter. 
  - This is where the application will use a short TTL (time-to-live) to resolve `localhost` (itself) as the first IPv4 address and a public (external) IPv4 address for me to perform another external-redirect-based SSRF attack.
  - I initially turned to a good old friend in [nip.io](https://nip.io/) which was missing the (_IP_) notiation I was looking for after admittingley prioritizing others like hexadecimal, decimal and octal which didn't hit lucky red for me in this case. 

- I performed a Google search for "_DNS Rebinding Service_" and found Tavis Ormandy's fantastic DNS rebinding server tool [rbndr](https://lock.cmpxchg8b.com/rebinder.html) ([rbndr Git](https://github.com/taviso/rbndr)).
  - I.E, an example payload using `127.0.0.1` as the first IPv4 address and `1.1.1.1` (randomly chosen) as the second IPv4 address provides me:

`http://7f000001.01010101.rbndr.us:8080`

If the address doesn’t make sense, that is hexadecimal notation for the internal IPv4 address and then the public IPv4 address, followed by `rbndr.us:8080`.
<br>
  > **The hostname generated will resolve randomly to one of the addresses specified with a very low TTL (Time-To-Live).**

`http://7f000001.01010101.rbndr.us:8080`

  > `7f000001` (Hex format) = `127.0.0.1` (IPv4 dotted decimal format)
  
  > `01010101` (Hex format) = `1.1.1.1` (IPv4 dotted decimal format)


  > - 🧠 **Hint**, try `ping 7f000001` from your host to test what you see.
  
  > **Note**, depending on the TTL of the DNS request you may get a cached response and therefore may have to run this a few times and give it some time.

![image](https://user-images.githubusercontent.com/104169244/229268895-93083ea4-41e6-40e9-8c14-a299d2424947.png)

🙌 **Voila**!

* Right-click the page, `view page source` and haul your `X-Ctf-Flag` flag!

`[tanuki](b98e27ae8ae849787c1a0cbdc1b9a35c)`

![image](https://user-images.githubusercontent.com/104169244/229268905-38fad138-4c97-4ec3-bcd3-76b00ae4ae49.png)

----------------------------------------------------------------

## Tar
### [tar2zip](http://capture.local.thetanuki.io/tar2zip)

* 

`IN-PROGRESS`

----------------------------------------------------------------

## AES GCM Encryption
### [GEE CEE M - 1](http://capture.local.thetanuki.io/gee-cee-m)

* 

`IN-PROGRESS`

### [GEE CEE M - 2](http://capture.local.thetanuki.io/gee-cee-m-two)

* 

`IN-PROGRESS`

----------------------------------------------------------------

### [GTP & OTP](http://capture.local.thetanuki.io/gtp-otp)

* 

`IN-PROGRESS`

----------------------------------------------------------------

### [Graphicle](http://capture.local.thetanuki.io/graphicle-one) **1**:

* 

`IN-PROGRESS`

### [Graphicle](http://capture.local.thetanuki.io/graphicle-two) **2**:

* 

`IN-PROGRESS`

----------------------------------------------------------------

## Polyglot
### [Nyan](http://capture.local.thetanuki.io/nyan)

* 

`IN-PROGRESS`

----------------------------------------------------------------

### [RST](http://capture.local.thetanuki.io/rst) **1**:

* 

`IN-PROGRESS`

### [RST](http://capture.local.thetanuki.io/rst2) **2**:

* 

`IN-PROGRESS`

----------------------------------------------------------------

### Additional Items Not Mentioned in the Report

* This section is placed for any additional items that were not mentioned in the overall report and out OOS (out-of-scope).

  - Maintaining/persisting access
  - Lateral movement (not applicable as sandboxed environment)
  - Individual remediation items per-finding/exploit
  - Web-server SAST-discovered vulnerabilities (Nikto|SAST|DAST etc.)
  - Any other identified open socket protocols or port vulnerability techniques

The report (as this an emulated lab and sandboxed environment) does not include credentials or IP addresses in redacted or obfuscated format.
