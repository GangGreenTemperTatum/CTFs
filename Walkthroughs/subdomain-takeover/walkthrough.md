# **Subdomain takeover writeup**
**`WHOAMI`:** [@GangGreenTemperTatum](https://github.com/GangGreenTemperTatum), v1.0, 04-23-2023

[![GitHub GangGreenTemperTatum](https://img.shields.io/github/followers/GangGreenTemperTatum?label=follow&style=social)](https://github.com/GangGreenTemperTatum)

## **Index**:

| **#** | **Index**  |   |   |   |
|---|---|---|---|---|
| 1 | **Additional Resources and tools** |   |   |   |
| 2 | **What is a subdomain?** |   |   |   |
| 3 | **What is subdomain takeover and dangling domains?** |   |   |   |
| 4 | **Why should I be concerned about subdomain takeover?** |   |   |   |
| 5 | **How is subdomain takeover implemented at a high-level?** |   |   |   |
| 7 | **Subdomain takeover setup steps** |   |   |   |
| 8 | **How can I fix subdomain takeovers?** |   |   |   |
| 9 | **Subdomain takeover [Example 1] - Fastly** |   |   |   |
| 10 | **Subdomain takeover [Example 2] - Heroku** |   |   |   |
| 11 | **Subdomain takeover [Example 3] - Netflify** |   |   |   |

## **TODO:**

| **#** | **Index**  |   |   |   |
|---|---|---|---|---|
| 1 | **Add subdomain takeover examples for A-record host IPs in GCP and AWS** |   |   |   |

## **Additional Resources**:

- **Open bug bounty submissions and blog examples:**
  - [H1 blog](https://www.hackerone.com/application-security/guide-subdomain-takeovers)
  - [H1-#121461](https://hackerone.com/reports/121461)
  - [H1-#380158](https://hackerone.com/reports/380158)
  - [H1-#121461](https://hackerone.com/reports/121461)
  - [BC-#5659](https://forum.bugcrowd.com/t/bitly-subdomain-takeover/5659)
  - [🤑🤑🤑](https://hackerone.com/reports/38007)

<br>

- **RTFM:**
  - [Glossary](https://www.bugcrowd.com/glossary/subdomain-takeover/)
  - [Example Google Dorking cheatsheet](https://gist.github.com/sundowndev/283efaddbcf896ab405488330d1bbc06)
  - [Can I takeover XYZ?](https://github.com/EdOverflow/can-i-take-over-xyz)
  - [GitHub Topics](https://github.com/topics/subdomains-enumeration)
  - [DNS Dumpster](https://dnsdumpster.com/) is one example of many great web applications & domain research tool's for DNS-related OSINT and intel - See an example query [here](https://dnsdumpster.com/static/map/takemeoverforfuns.org.png)

<br>

# **Resources (tools)**:

| **#** | **DNS Recon Tool(s)**  |   |   |   |
|---|---|---|---|---|
| 1 | **[Google Dorking](https://gist.github.com/sundowndev/283efaddbcf896ab405488330d1bbc06)** |   |   |   |
| 2 | **[OWASP AMASS](https://owasp-amass.com/)** |   |   |   |
| 3 | **[Gobuster](https://www.kali.org/tools/gobuster/)** |   |   |   |
| 4 | **[knockpy](https://github.com/guelfoweb/knock/blob/master/README.md)** |   |   |   |
| 5 | **[cname.py](https://github.com/iw00tr00t/Nslookup-`C-Name`/blob/master/cname.py)** |   |   |   |
| 5.1 | **[cname.sh](https://github.com/sumgr0/cname-check)** |   |   |   |
| 6 | **[anew](https://github.com/tomnomnom/anew)** |   |   |   |

| **#** | **Server Recon Tool(s)**  |   |   |   |
|---|---|---|---|---|
| 1 | **[sub404](https://github.com/r3curs1v3-pr0xy/sub404)** |   |   |   |
| 2 | **[nuclei](https://github.com/projectdiscovery/nuclei)** |   |   |   |
| 3 | **[tko-subs](https://github.com/anshumanbh/tko-subs)** |   |   |   |
| 4 | **[subjack](https://github.com/haccer/subjack)** |   |   |   |
| 5 | **[httpx](https://github.com/projectdiscovery/httpx)** |   |   |   |

| **#** | **Other Recon Tool(s)**  |   |   |   |
|---|---|---|---|---|
| 1 | **[dig](https://linux.die.net/man/1/dig)** | `% dig +short TXT takemeoverforfuns.org \ "v=spf1 include:spf.efwd.registrar-servers.com ~all"`  |   |   |
| 2 | **[cURL](https://curl.se/)** | `cURL` is a swiss-army knife for any ITSec professional.  |   |   |

> - To enhance efficiency, here's a couple of `bash.profile` or `.zshrc` aliases I created and recommended for recon using cUrl and dig:

```
# prettydig:    Format human readable output from `dig` to `dig +noall +answer +multiline yourdomain.yourtld any`
alias prettydig='dig +noall +answer +multiline'

# curlredirect  Instruct curl to follow redirects (this flag is not enabled by default)
alias curlredirect='curl -L'

# curlheaders   Instruct curl to only print headers and follow redirect
alias curlheaders='curl -iIL -H "Accept: application/json" -H "Content-Type: application/json" -X GET'
```

<br>

## **What is a subdomain?**

> - A subdomain is a domain entity that is a part of a larger domain under the Domain Name System (DNS) hierarchy.
>   - It is used as an easy way to create a more memorable Web address for specific or unique content with a website.
>   - I.E, an `A`-Record being a hostname to IPv4 address is not scalable for clients to enter https://8.8.8.8 when wanting to browser Google search engine.
> - Example of a domain broken down: The domain `takemeoverforfuns.org`, could be interpreted as URL to the "main" website. A domain consists of two parts:
>   - The `TLD` (top level domain) which is the `.org` part (or another domain extension), and
>   - The `SLD` (second level domain), `takemeoverforfuns`, the name that you buy from a domain registrar.

<br>

### **`C`-Name vs `A`-Record (AKA "`AAAA`" within IPv6) in DNS Records:**

> - `A`-Record and `C-Name` records are standard DNS records within IPv4.
>   - An `A`-Record <span style="color:red">*maps a hostname to one or more IP addresses*</span>, while the `C-Name` record <span style="color:red">*maps a hostname to another hostname or alias*</span>.
>     - The `A`-record maps a name to one or more IPv4 addresses when the IPv4 are known and stable.
>     - The `C-Name` (canonical) record maps a name to another name. It should only be used when there are no other records on that name.
>   - Additionally, `C-Name` records establish a connection between a parent domain and subdomains.
>     - Whenever we have multiple `C-Name` records, the first `C-Name` record will redirect us to next `C-Name` record and so on. The redirection would continue until we reach last `C-Name` record in a recursive process.

> - **Reversing DNS Record Lookups:**

>  - `A`-Record reverse lookups are known as a `PTR` lookup. A reverse DNS record (or `PTR` record) is simply an entry that resolves an IP address back to a host name)
>     - Example online resource [here](https://mxtoolbox.com/ReverseLookup.aspx).
>     - ZSH/Bash terminal = `# host <a-record>` (where `<a-record>` is the IPv4/IPv6 address)
>     - Dig = `# dig -x <a-record>` (where `<a-record>` is the IPv4/IPv6 address)
>     - NSLookup = `# nslookup <a-record>` (where `<a-record>` is the IPv4/IPv6 address)
>  - `C`-Name
>     - It is not possible to reverse-lookup a `C`-Name record

<br>

## **What is Subdomain Takeover and What are Dangling Domains?**

> - Subdomain takeover occurs when an attacker take control over a subdomain of a domain. It most commonly happens because of DNS misconfiguration / mistakes.
> - A subdomain takeover can occur when you have a DNS record that points to a deprovisioned remote resource where the DNS records are still active. Such DNS records are also known as `"dangling DNS"` entries, or I like to think of "prime for the pickin!'".
> - Taking the above into account, `C-Name` records can be additionally and perceived "*more dangerous*" compared to `A`-records, since it's much harder for an attacker to control remote resources that have a fixed IPv4 address that especially belong to a specific CIDR netblock, rather than hostname which is most commonly a remote service such as CDN's, web app builders, load balancers, cloud infrastructure *etc*.

<br>

## **Why Should I be Concerned About Subdomain Takeover?**

> - Misconfiguration of your DNS records by not keeping them up-to-date can leave dangling domains within your DNS infrasture and leave you susceptible to subdomain takeover which could even further lead to:
> - - Brand reputational damage
> - - Financial loss
> - - Risk to customers and personal data from masquerading applications (similar to domain typo squat's)
> - - Loss of control over your actual infrastructure
> - - Financial loss when awarding potential bug bounty submissions for these finding's alone
> - - It's a simple and nonsophisticated vulnerability that can exploited by a hacker with an inexperienced skillset

> [March 22, 2022](https://blog.detectify.com/2022/03/22/subdomain-takeover-on-the-rise-detectify-research/#:~:text=Over%20the%20past%20year%2C%20we,increased%20as%20much%20as%2025%25.) 🧠 *New research from **Detectify**, the SaaS security company powered by ethical hackers, shows that Subdomain takeovers are on the rise but are also getting harder to monitor as domains now seem to have more vulnerabilities in them. In 2021, Detectify detected 25% more vulnerabilities in its customers’ web assets compared to 2020 with twice the median number of vulnerabilities per domain, demonstrating the outsized impact an External Attack Surface Monitoring (EASM) tool can have on an organization’s security programme.*

> - <span style="color:red">**Example scenario..**</span>
>   - Bob, decides to provision a web application and associated PaaS, then configures a `C-Name` DNS record to point traffic to that domain to his remote service
>   - Sally takes over this project at a later stage and commences with the decomission since it was a completed PoC that never saw full fruition
>   - Sally is unaware of any external DNS records may have created and doesn't have a process to check this as part of the decomission
>   - When it's hard to keep a lock on DNS configuration and permissions, who if anyone remembers to cover Bob's back by updating the DNS records with it!?
>   - This leaves a "`dangling domain`" lurking within our ecosystem

<br>

## **How is Subdomain Takeover Implemented at a High-Level?**

> - Theoretically, a Subdomain Takeover flaw is when an attacker can hijack the subdomain of a company, and thus control or masquerade as your company and additionally trick your legitimate customers
>   - If an attacker is able to locate a "dangling domain" from a deprovisioned remote resource, they may be able to claim that resource (with your DNS records still intact) and control your remote resource.
>   - Further exploit techniques could be masquerading as your business and leading your customers as victim's to untrusted and remote hacker controlled servers who think they are using your legitimate service.

## **How Can I Fix Subdomain Takeovers?**

1) Ensure DNS records are up-to-date and correctly reflect the state of your infrastructure
   1) If a service has been decommissioned and no longer required, ensure to update your DNS records to reflect this
2) Ensure all access to DNS configuration is managed and structured with RBAC and least privilege in mind
   1) Keep a correct reflective state of all your remote services in accordance with your DNS settings
3) Setup your own subdomain takeover techniques within your business to identify dangling domains, and|or implement real-time detection of dangling domains within your infrastructure

### **What Can be Done as an Industry Standard to Help Prevent Subdomain Takeovers?**

1) I was originally planning to use `GitHub` pages as an example. However, it seems that GitHub have introduced [custom domain validation](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/verifying-your-custom-domain-for-github-pages) which prevents this.
   1) This is a common technique which is being implemented by many platform providers to prevent SubDomain Takeovers.
   2) I recommend checking a resource such as [`canitakeoverxyz`](https://github.com/EdOverflow/can-i-take-over-xyz) or try perform the takeover yourself.

<br>

## **Subdomain Takeover Setup Steps**

> - From the tools listed above, these are the most common tools you will need for each PoC scenario, regardless of which platform the hijacked domain resides on

> - Within the examples listed below, my TLD (top-level domain) used is [`takemeoverforfuns.org`](https://toolbox.googleapps.com/apps/dig/#A/%3Fquery%3Dtakemeoverforfuns.org), **let's hunt!**
>   - For examples sake, within our **DNS Recon** section, I added a bunch of phony random `A`-records and `C`-Name records to provide elaboration of how certain subdomains may be detected from scanning, and others that require more complex methods or additional wordlist parsing.

<br>

## **DNS Recon**: 😈
<br>

### **Subdomain enumeration tools**:

> - I would recommend using a combination of some of the open source tools mentioned below, or additional/replacing some tools with others of your choice to getting a general concensus and ensure one tool isn't missing something that could be spotted by another.

<br>

### [`Google Dorking`](https://chryzsh.gitbooks.io/pentestbook/content/finding_subdomains.html):

> - Google Dorking is quick, easy and can be used in attempt to find subdomains, here are a couple of examples which can be entered into the Google Search bar:
>  - The disadvantage is that it's not very efficient when dealing with multiple subdomains.

```
# Passive Subdomain Enumeration examples using Google Dorking:
site:*.redacted.com -www -www1 -blog
site:*.*.redacted.com -product
```

- [Example here](https://www.google.com/search?q=site%3A*.takemeoverforfuns.org&source=hp&ei=g75ZZJ_HFceG0PEP0LKH8A8&iflsig=AOEireoAAAAAZFnMkwk61Fn4YGMLIhVjiCqFdumgwrT_&ved=0ahUKEwjflP-Zpuf-AhVHAzQIHVDZAf4Q4dUDCAs&uact=5&oq=site%3A*.takemeoverforfuns.org&gs_lcp=Cgdnd3Mtd2l6EANQAFjXoQFg2qQBaAFwAHgAgAE-iAFukgEBMpgBAKABAqABAQ&sclient=gws-wiz)
- **Note**: Some results may not yield if they are not indexed, I.E serve web content to be picked up by Google's crawlers,

### [`OWASP AMASS`](https://owasp-amass.com/):

> - [OWASP](https://owasp.org) Amass is a great subdomain enumeration tool that comes pre-installed on Kali Linux operating system. Here is an example use-case:
>   - `-d` meaning the domain in question you are attacking
>   - `-o` meaning to output your results to a text file

```
# Passive Subdomain Enumeration using OWASP Amass - Example of a single domain to file
$ amass enum -passive -d redacted.com -config config.ini -o amass_passive_subs.txt

# Passive Subdomain Enumeration using OWASP Amass - Example of a single domain to stdout
$ amass enum -passive -d takemeoverforfuns.org
www.takemeoverforfuns.org
takemeoverforfuns.org
```

### [`Gobuster`](https://www.kali.org/tools/gobuster/):

> - Written in GoLang, lightweight and fast; GoBuster is a phenomenal tool for many uses which is capable of performing subdomain enumeration. Here is an example use-case:
> - `-d` meaning the domain in question you are attacking
> - `-w` meaning you can utilize a custom wordlist (mandatory) in attempt to match subdomains within the DNS structure
>   - I personally recommend [Jason' Haddix's excellent and very extensive "all wordlists from every dns enumeration" list](https://gist.github.com/jhaddix/86a06c5dc309d08580a018c66354a056) or [The all-time "Seclists"](https://github.com/danielmiessler/SecLists)
> - `-o` meaning to output your results to a text file

```
# Utilize the built-in help syntax:
$ gobuster dns -h

# Subdomain Brute force examples using Gobuster:
$ gobuster dns -d redacted.com -w wordlist.txt - show-cname - no-color -o gobuster_subs.txt
$ gobuster dns -d takemeoverforfuns.org -w ~/git/SecLists/Discovery/DNS/dns-Jhaddix.txt --verbose - show-cname
```

> - Here is an example of GoBuster being used in the wild on our example domain for this PoC:

```
gobuster % gobuster dns -d takemeoverforfuns.org -w ~/git/SecLists/Discovery/DNS/subdomains-top1million-5000.txt - show-cname -o ~/subdomains.txt
===============================================================
Gobuster v3.5
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Domain:     takemeoverforfuns.org
[+] Threads:    10
[+] Timeout:    1s
[+] Wordlist:   /Users/X/git/SecLists/Discovery/DNS/subdomains-top1million-5000.txt
===============================================================
2023/05/11 20:48:22 Starting gobuster in DNS enumeration mode
===============================================================
2023/05/11 20:48:22 [-] Unable to validate base domain: takemeoverforfuns.org (lookup takemeoverforfuns.org: no such host) <--- This means that there is no A-record for the base domain name itself.

Found: a.takemeoverforfuns.org
Found: b.takemeoverforfuns.org
Found: 1.takemeoverforfuns.org
Found: 4.takemeoverforfuns.org

Progress: 4952 / 4990 (99.24%)
===============================================================
2023/05/11 20:48:41 Finished
===============================================================
```

![Screenshot 2023-05-21 at 9 34 11 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/876bba8e-ecbe-4349-a217-0a441f460671)

### [`knockpy`](https://github.com/guelfoweb/knock)

> - Knockpy is a portable and modular python3 tool designed to quickly enumerate subdomains on a target domain through passive reconnaissance and dictionary scan.

```
# Subdomain Brute force examples using Knock:
$ python3 knockpy.py domain.com
$ python3 knockpy.py takemeoverforfuns.org -o false
```

> - Here is an example of Knock being used in the wild on our example domain for this PoC:

```
knock % python3 knockpy.py takemeoverforfuns.org -o false

  _  __                 _
 | |/ /                | |   v6.1.0
 | ' / _ __   ___   ___| | ___ __  _   _
 |  < | '_ \ / _ \ / __| |/ / '_ \| | | |
 | . \| | | | (_) | (__|   <| |_) | |_| |
 |_|\_\_| |_|\___/ \___|_|\_\ .__/ \__, |
                            | |     __/ |
                            |_|    |___/

local: 10757 | remote: 1

Wordlist: 10758 | Target: takemeoverforfuns.org | Ip: None

03:43:46

Ip address      Code Subdomain                                     Server                                        Real hostname
--------------- ---- --------------------------------------------- --------------------------------------------- ---------------------------------------------
34.125.194.13        1.takemeoverforfuns.org
34.125.194.13        4.takemeoverforfuns.org
34.125.194.13        a.takemeoverforfuns.org
34.125.194.13        b.takemeoverforfuns.org

03:44:16

Ip address: 1 | Subdomain: 4 | elapsed time: 00:00:29
```

![Screenshot 2023-05-21 at 9 33 38 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/53124817-09da-4ffe-9582-ea595c1a62de)


<br>

## **Other Tools**: 👿
## Organize Your Subdomain Results with [anew](https://github.com/tomnomnom/anew): 👿

<br>

> - If using a combination of the above tools for reconnaisaince, you may indeed have duplicate results.
> - I found this great tool from Tom Anew (*kudos and thank you!*) which is great for filtering through the weeds for building a structured single source of truth.

<br>

## Enumerate `C-Name` Records from Subdomains: 👿

> - From the identified list of subdomains via `A`-record's as they are enumerating DNS lookups using a provided wordlist as an input and not an actual "real name" which may relate to a service. Example such as "`devsherokuplanning.takemeoverforfuns.org`".
> - Depending on how sophisticated the wordlist or scanning engine is, our results from this may look something like:
>   - `a.takemeoverforfuns.org` -> `<ipaddr>`
>   - `b.takemeoverforfuns.org` -> `<ipaddr>`
>   - `c.takemeoverforfuns.org` -> `<ipaddr>`
> - Therefore, we need a tool or script which will enumerate `C`-Name DNS records for these identified subdomains to ensure we catch both subdomains as `A`-records and `C`-Name aliases.
> - [Here](https://github.com/iw00tr00t/Nslookup-`C-Name`/blob/master/cname.py) or [Here](https://github.com/sumgr0/cname-check) are great example's of simple scripts to enumerate `C-Name`S from the list of URLs given.

```
# Example of enumerating C-Name records with this script:
$ bash cname.sh subdomain_file
$ ls -halt | grep cname
-rw-r--r--   1 <user>  staff  -   22B  9 May 19:41 no_cname <--- Domains that do not have a C-Name record
-rw-r--r--   1 <user>  staff  -  130B  9 May 19:41 cname_out <--- Domains that have a C-Name record, including the mapping
```

> - Here is an example of cname.sh being used in the wild on our example domain for this PoC:

```
~ % ./cname.sh takemycnames.txt
       4 takemycnames.txt
no_cname: 1; host_match: 0; cname_out: 3
~ %
~ % cat no_cname
takemynetlify.takemeoverforfuns.org
~ %
~ % cat cname_out
takemyfastly.takemeoverforfuns.org ==> nonssl.global.fastly.net.
takemyheroku.takemeoverforfuns.org ==> takemyheroku.herokuapp.com.
github.takemeoverforfuns.org ==> ganggreentempertatum.github.io.
```

![Screenshot 2023-05-21 at 9 41 11 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/9bbf9ddc-21e6-4ea0-a9ad-b7af617084d9)

## **Domain/Server Recon**: 😈

> - Now we have our results from subdomain enumeration, rather than loop a script to iterating if each one is a potential dangling domain, here are some tools which can produce results to indicate potential dangling domains from a list of subdomains.
> - Below, I provide some insight and live output on server recon using these tools with the following `subdomains.txt` from my prior DNS recon:

```
~ % cat subdomains.txt
a.takemeoverforfuns.org
b.takemeoverforfuns.org
1.takemeoverforfuns.org
4.takemeoverforfuns.org
takemyfastly.takemeoverforfuns.org
takemyheroku.takemeoverforfuns.org
github.takemeoverforfuns.org
takemynetlify.takemeoverforfuns.org
```

### [`sub404`](https://github.com/r3curs1v3-pr0xy/sub404)

> - Sub 404 is a tool written in python which is used to check possibility of subdomain takeover vulnerability and it is fast as it is asynchronous. It isn't very verbose or detailed in it's methods which I am personally not too keen on.
> - My other hesitation with `sub404` is that check.
> - For example, Fastly takeover's may return a `500` HTTP server error in response:

```
sub404 % python3 sub404.pY -f ~/subdomains.txt -p http,https

		     ____        _       _  _    ___  _  _
		    / ___| _   _| |__   | || |  / _ \| || |
		    \___ \| | | | '_ \  | || |_| | | | || |_
		     ___) | |_| | |_) | |__   _| |_| |__   _|
		    |____/ \__,_|_.__/     |_|  \___/   |_|

                       			- By r3curs1v3_pr0xy


[-] Reading file /Users/X/subdomains.txt
[-] Gathering Information...
[-] Total Unique Subdomain Found:  8
[-] Default http [use -p https]
[-] Checking response code...
|[-] Getting URL's of 404 status code...
[-] URL Checked: 8
[*] Task Completed :)
[!] Target is not vulnerable!!!
```

![Screenshot 2023-05-21 at 9 59 02 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/1d0cdbea-4b0e-4ad4-b859-651f3d9b86f6)

> - Perform a cURL attempt to verify the legitimacy of the claim shows a 404 is returned for the subdomain!

```
sub404 % curl takemyfastly.takemeoverforfuns.org
Fastly error: unknown domain: takemyfastly.takemeoverforfuns.org. Please check that this domain has been added to a service.
Details: cache-yyc1430022-YYC

sub404 % curlheaders takemyfastly.takemeoverforfuns.org
HTTP/1.1 500 Domain Not Found
Connection: keep-alive
Content-Length: 291
Server: Varnish
Retry-After: 0
content-type: text/html
Cache-Control: private, no-cache
X-Served-By: cache-yyc1430023-YYC
Accept-Ranges: bytes
Date: Wed, 10 May 2023 03:08:49 GMT
Via: 1.1 varnish
```

> - In some cases, the domain could be indeed dangling, but a 500 server error is returned which can give us misleading results:

```
sub404 % curlheaders takemyfastly.takemeoverforfuns.org
HTTP/1.1 500 Domain Not Found
Connection: keep-alive
Content-Length: 291
Server: Varnish
Retry-After: 0
content-type: text/html
Cache-Control: private, no-cache
X-Served-By: cache-yyc1430030-YYC
Accept-Ranges: bytes
Date: Mon, 22 May 2023 04:49:22 GMT
Via: 1.1 varnish
```

![Screenshot 2023-05-21 at 9 50 21 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/26abc36b-bb4c-43a2-9946-f7711dbe9ca1)

### [`nuclei`](https://github.com/projectdiscovery/nuclei):

```
~ % nuclei -l ~/subdomains.txt -t ~/nuclei-templates/detect-all-takeovers.yaml -v -ts -sa -uc

                     __     _
   ____  __  _______/ /__  (_)
  / __ \/ / / / ___/ / _ \/ /
 / / / / /_/ / /__/ /  __/ /
/_/ /_/\__,_/\___/_/\___/_/   v2.9.1

		projectdiscovery.io

[DBG] [2023-05-21T21:59:34-07:00] scanAllIps: no ip's found reverting to default
[DBG] [2023-05-21T21:59:35-07:00] scanAllIps: no ip's found reverting to default
[INF] Running uncover query against:
[INF] Using Nuclei Engine 2.9.1 (outdated)
[INF] Using Nuclei Templates 9.5.0 (latest)
[INF] Templates added in last update: 62
[INF] Templates loaded for scan: 1
[INF] Targets loaded for scan: 17
[INF] Running httpx on input host
[INF] Found 12 URL from httpx
[VER] [2023-05-21T22:00:15-07:00] [detect-all-takeovers] Sent HTTP request to http://takemyfastly.takemeoverforfuns.org/
[VER] [2023-05-21T22:00:15-07:00] [detect-all-takeovers] Sent HTTP request to http://takemyfastly.takemeoverforfuns.org/
[2023-05-21 22:00:15] [detect-all-takeovers:fastly] [http] [high] http://takemyfastly.takemeoverforfuns.org/
[2023-05-21 22:00:15] [detect-all-takeovers:fastly] [http] [high] http://takemyfastly.takemeoverforfuns.org/
[VER] [2023-05-21T22:00:15-07:00] [detect-all-takeovers] Sent HTTP request to http://takemyfastly.takemeoverforfuns.org/
[VER] [2023-05-21T22:00:15-07:00] [detect-all-takeovers] Sent HTTP request to http://takemyfastly.takemeoverforfuns.org/
[2023-05-21 22:00:15] [detect-all-takeovers:fastly] [http] [high] http://takemyfastly.takemeoverforfuns.org/
[2023-05-21 22:00:15] [detect-all-takeovers:fastly] [http] [high] http://takemyfastly.takemeoverforfuns.org/
[VER] [2023-05-21T22:00:16-07:00] [detect-all-takeovers] Sent HTTP request to https://github.takemeoverforfuns.org/
[VER] [2023-05-21T22:00:16-07:00] [detect-all-takeovers] Sent HTTP request to https://github.takemeoverforfuns.org/
[VER] [2023-05-21T22:00:16-07:00] [detect-all-takeovers] Sent HTTP request to https://github.takemeoverforfuns.org/
[VER] [2023-05-21T22:00:16-07:00] [detect-all-takeovers] Sent HTTP request to https://github.takemeoverforfuns.org/
[VER] [2023-05-21T22:00:16-07:00] [detect-all-takeovers] Sent HTTP request to https://takemyheroku.takemeoverforfuns.org/
[2023-05-21 22:00:16] [detect-all-takeovers:heroku] [http] [high] https://takemyheroku.takemeoverforfuns.org/
[VER] [2023-05-21T22:00:16-07:00] [detect-all-takeovers] Sent HTTP request to https://takemyheroku.takemeoverforfuns.org/
[VER] [2023-05-21T22:00:16-07:00] [detect-all-takeovers] Sent HTTP request to https://takemyheroku.takemeoverforfuns.org/
[2023-05-21 22:00:16] [detect-all-takeovers:heroku] [http] [high] https://takemyheroku.takemeoverforfuns.org/
[2023-05-21 22:00:16] [detect-all-takeovers:heroku] [http] [high] https://takemyheroku.takemeoverforfuns.org/
[VER] [2023-05-21T22:00:16-07:00] [detect-all-takeovers] Sent HTTP request to https://takemyheroku.takemeoverforfuns.org/
[2023-05-21 22:00:16] [detect-all-takeovers:heroku] [http] [high] https://takemyheroku.takemeoverforfuns.org/
```

![Screenshot 2023-05-21 at 10 00 53 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/b54b17e5-1f8e-41b0-a76c-58ded931b087)

### [`tko-subs`](https://github.com/anshumanbh/tko-subs):

> - `tko-subs` is slightly more in-depth and complex but actually offers a takeover feature.
> - As the purpose of this write up is to simplify the Sub Domain Takeover process in simple terms, see a useful guide for tko-subs usage [here](https://securityonline.info/tko-subs/).

### [`subjack`](https://github.com/haccer/subjack):

> - Subjack is a Subdomain Takeover tool written in Go designed to scan a list of subdomains concurrently and identify ones that are able to be hijacked. With Go's speed and efficiency, this tool really stands out when it comes to mass-testing. Always double check the results manually to rule out false positives.

```
~ % subjack -w ~/subdomains.txt -t 100 -timeout 30 -v
[Not Vulnerable] 2.takemeoverforfuns.org
[Not Vulnerable] 2.takemeoverforfuns.org
[FASTLY] takemyfastly.takemeoverforfuns.org
[Not Vulnerable] takemyfastly.takemeoverforfuns.org
[Not Vulnerable] github.takemeoverforfuns.org
[Not Vulnerable] github.takemeoverforfuns.org
[Not Vulnerable] takemynetlify.takemeoverforfuns.org
[Not Vulnerable] takemynetlify.takemeoverforfuns.org
[HEROKU] takemyheroku.takemeoverforfuns.org
[Not Vulnerable] takemyheroku.takemeoverforfuns.org
[Not Vulnerable] b.takemeoverforfuns.org
[Not Vulnerable] b.takemeoverforfuns.org
[Not Vulnerable] a.takemeoverforfuns.org
[Not Vulnerable] a.takemeoverforfuns.org
[Not Vulnerable] 1.takemeoverforfuns.org
[Not Vulnerable] 1.takemeoverforfuns.org
```

![Screenshot 2023-05-21 at 10 01 57 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/41c6ba5b-59a1-4978-ae3d-6971d602583d)

### [`httpx`](https://github.com/projectdiscovery/httpx):

> - `httpx` is a fast and multi-purpose HTTP toolkit that allows running multiple probes using the retryable http library. It is designed to maintain result reliability with an increased number of threads.
> - I love how httpx can print the output of probe success validation as well as the status code which can be sorted and filtered:

```
~ % httpx -l subdomains.txt -p 80,443,8080,3000 -status-code -title -o servers_details.txt -v

    __    __  __       _  __
   / /_  / /_/ /_____ | |/ /
  / __ \/ __/ __/ __ \|   /
 / / / / /_/ /_/ /_/ /   |
/_/ /_/\__/\__/ .___/_/|_|
             /_/

		projectdiscovery.io

[INF] Current httpx version v1.3.1 (latest)
[DBG] Failed 'http://takemyfastly.takemeoverforfuns.org:443': GET http://takemyfastly.takemeoverforfuns.org:443 giving up after 1 attempts: Get "http://takemyfastly.takemeoverforfuns.org:443": could not connect to any port found for host
https://github.takemeoverforfuns.org [200] [Ad's GitHub PoC]
[DBG] Failed 'http://2.takemeoverforfuns.org:8080': GET http://2.takemeoverforfuns.org:8080 giving up after 1 attempts: Get "http://2.takemeoverforfuns.org:8080": no port found for host
[DBG] Failed 'http://2.takemeoverforfuns.org:443': GET http://2.takemeoverforfuns.org:443 giving up after 1 attempts: Get "http://2.takemeoverforfuns.org:443": no port found for host
[DBG] Failed 'http://2.takemeoverforfuns.org:80': GET http://2.takemeoverforfuns.org:80 giving up after 1 attempts: Get "http://2.takemeoverforfuns.org:80": no port found for host
[DBG] Failed 'http://2.takemeoverforfuns.org:3000': GET http://2.takemeoverforfuns.org:3000 giving up after 1 attempts: Get "http://2.takemeoverforfuns.org:3000": no port found for host
http://takemyfastly.takemeoverforfuns.org [] [Fastly error: unknown domain takemyfastly.takemeoverforfuns.org]
https://takemyheroku.takemeoverforfuns.org [404] [Heroku | Application Error]
[DBG] Failed 'http://takemynetlify.takemeoverforfuns.org:3000': GET http://takemynetlify.takemeoverforfuns.org:3000 giving up after 1 attempts: Get "http://takemynetlify.takemeoverforfuns.org:3000": no port found for host
[DBG] Failed 'http://takemynetlify.takemeoverforfuns.org:443': GET http://takemynetlify.takemeoverforfuns.org:443 giving up after 1 attempts: Get "http://takemynetlify.takemeoverforfuns.org:443": no port found for host
[DBG] Failed 'http://takemynetlify.takemeoverforfuns.org:80': GET http://takemynetlify.takemeoverforfuns.org:80 giving up after 1 attempts: Get "http://takemynetlify.takemeoverforfuns.org:80": no port found for host
http://github.takemeoverforfuns.org [301] [301 Moved Permanently]
[DBG] Failed 'http://takemynetlify.takemeoverforfuns.org:8080': GET http://takemynetlify.takemeoverforfuns.org:8080 giving up after 1 attempts: Get "http://takemynetlify.takemeoverforfuns.org:8080": no port found for host
http://takemyheroku.takemeoverforfuns.org [404] [Heroku | Application Error]
[DBG] Failed 'http://1.takemeoverforfuns.org:80': GET http://1.takemeoverforfuns.org:80 giving up after 1 attempts: Get "http://1.takemeoverforfuns.org:80": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://a.takemeoverforfuns.org:443': GET http://a.takemeoverforfuns.org:443 giving up after 1 attempts: Get "http://a.takemeoverforfuns.org:443": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://b.takemeoverforfuns.org:3000': GET http://b.takemeoverforfuns.org:3000 giving up after 1 attempts: Get "http://b.takemeoverforfuns.org:3000": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://takemyfastly.takemeoverforfuns.org:8080': GET http://takemyfastly.takemeoverforfuns.org:8080 giving up after 1 attempts: Get "http://takemyfastly.takemeoverforfuns.org:8080": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://1.takemeoverforfuns.org:3000': GET http://1.takemeoverforfuns.org:3000 giving up after 1 attempts: Get "http://1.takemeoverforfuns.org:3000": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://1.takemeoverforfuns.org:443': GET http://1.takemeoverforfuns.org:443 giving up after 1 attempts: Get "http://1.takemeoverforfuns.org:443": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://b.takemeoverforfuns.org:80': GET http://b.takemeoverforfuns.org:80 giving up after 1 attempts: Get "http://b.takemeoverforfuns.org:80": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://b.takemeoverforfuns.org:8080': GET http://b.takemeoverforfuns.org:8080 giving up after 1 attempts: Get "http://b.takemeoverforfuns.org:8080": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://a.takemeoverforfuns.org:8080': GET http://a.takemeoverforfuns.org:8080 giving up after 1 attempts: Get "http://a.takemeoverforfuns.org:8080": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://takemyheroku.takemeoverforfuns.org:3000': GET http://takemyheroku.takemeoverforfuns.org:3000 giving up after 1 attempts: Get "http://takemyheroku.takemeoverforfuns.org:3000": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://b.takemeoverforfuns.org:443': GET http://b.takemeoverforfuns.org:443 giving up after 1 attempts: Get "http://b.takemeoverforfuns.org:443": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://1.takemeoverforfuns.org:8080': GET http://1.takemeoverforfuns.org:8080 giving up after 1 attempts: Get "http://1.takemeoverforfuns.org:8080": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://a.takemeoverforfuns.org:80': GET http://a.takemeoverforfuns.org:80 giving up after 1 attempts: Get "http://a.takemeoverforfuns.org:80": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://a.takemeoverforfuns.org:3000': GET http://a.takemeoverforfuns.org:3000 giving up after 1 attempts: Get "http://a.takemeoverforfuns.org:3000": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://github.takemeoverforfuns.org:8080': GET http://github.takemeoverforfuns.org:8080 giving up after 1 attempts: Get "http://github.takemeoverforfuns.org:8080": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://takemyheroku.takemeoverforfuns.org:8080': GET http://takemyheroku.takemeoverforfuns.org:8080 giving up after 1 attempts: Get "http://takemyheroku.takemeoverforfuns.org:8080": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://github.takemeoverforfuns.org:3000': GET http://github.takemeoverforfuns.org:3000 giving up after 1 attempts: Get "http://github.takemeoverforfuns.org:3000": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
[DBG] Failed 'http://takemyfastly.takemeoverforfuns.org:3000': GET http://takemyfastly.takemeoverforfuns.org:3000 giving up after 1 attempts: Get "http://takemyfastly.takemeoverforfuns.org:3000": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
```

![Screenshot 2023-05-21 at 10 10 12 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/a320bf48-fe05-451f-9c37-ec6cadc15641)

> - Or, written as:

```
~ % cat subdomains.txt| httpx -probe -status-code -v -title
```

<br>
<br>

### **PoC host**: 😶‍🌫️

> - Unless this is a fully functioning and maintained site, I recommend using a scratch image on your PoC host EC2 image.. don't be PWNED yourself!
> - Below is an example machine startup script you can use to a simple scratch-Apache image to host your own static content showing off your PoC:

```
 #! /bin/bash
 sudo apt update
 sudo apt -y install apache2
 cat <<EOF > /var/www/html/index.html
 <html><body><h1>GangGreenTemperTatum PoC!</h1><p><a href="https://github.com/GangGreenTemperTatum">Visit my GitHub page</a></p></body></html>
 EOF
 ```

![Screenshot 2023-05-21 at 10 52 59 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/6dd569f7-bc39-4850-900f-6c228d126568)

> - I recommend checking out [reserved static IP addresses](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#promote_ephemeral_ip) as an example for public IPv4/IPv6 allocation to your VM infrastructure.
> - Verify you can hit your PoC and is accessible:

```
$ nc -vz <poc-server> <80|443>
```

<br>

## **Subdomain takeover [Example 1]** `Fastly`

- In this example, our recon has lead us to identify the domain `takemeoverforfuns.org` has a subdomain (via `C`-Name record) `takemyfastly.takemeoverforfuns.org` which is pointing to the [Fastly](https://Fastly.net) CDN content provider, output from `dig` below:
  - A `whois` of the TLD|SLD within the `C-Name` and associated IPv4 addresses further identifies this is Fastly-owned netblock space and domain registry.

- The recon phase has also shown us that we are receiving either `404` or `500` HTTP responses from the server which could identify a potential dangling domain.
  - The `[]` indicated for status code AKA `500` which you can validate with a simple `curl` command printing the response headers

```
~ % httpx -l subdomains.txt -p 80,443,8080,3000 -status-code -title -o servers_details.txt -v

    __    __  __       _  __
   / /_  / /_/ /_____ | |/ /
  / __ \/ __/ __/ __ \|   /
 / / / / /_/ /_/ /_/ /   |
/_/ /_/\__/\__/ .___/_/|_|
             /_/

		projectdiscovery.io

[INF] Current httpx version v1.3.1 (latest)
[DBG] Failed 'http://takemyfastly.takemeoverforfuns.org:443': GET http://takemyfastly.takemeoverforfuns.org:443 giving up after 1 attempts: Get "http://takemyfastly.takemeoverforfuns.org:443": could not connect to any port found for host
https://github.takemeoverforfuns.org [200] [Ad's GitHub PoC]
[DBG] Failed 'http://2.takemeoverforfuns.org:8080': GET http://2.takemeoverforfuns.org:8080 givin
g up after 1 attempts: Get "http://2.takemeoverforfuns.org:8080": no port found for host
[DBG] Failed 'http://2.takemeoverforfuns.org:443': GET http://2.takemeoverforfuns.org:443 giving up after 1 attempts: Get "http://2.takemeoverforfuns.org:443": no port found for host
[DBG] Failed 'http://2.takemeoverforfuns.org:80': GET http://2.takemeoverforfuns.org:80 giving up after 1 attempts: Get "http://2.takemeoverforfuns.org:80": no port found for host
[DBG] Failed 'http://2.takemeoverforfuns.org:3000': GET http://2.takemeoverforfuns.org:3000 giving up after 1 attempts: Get "http://2.takemeoverforfuns.org:3000": no port found for host
http://takemyfastly.takemeoverforfuns.org [] [Fastly error: unknown domain takemyfastly.takemeoverforfuns.org]
```

- Or simply read:

```
~ % cat ~/git/sub404/cname_out | httpx -probe -status-code

    __    __  __       _  __
   / /_  / /_/ /_____ | |/ /
  / __ \/ __/ __/ __ \|   /
 / / / / /_/ /_/ /_/ /   |
/_/ /_/\__/\__/ .___/_/|_|
             /_/

		projectdiscovery.io

[INF] Current httpx version v1.3.1 (latest)
http://takemyfastly.takemeoverforfuns.org [SUCCESS] []
```

![Screenshot 2023-05-22 at 12 05 14 AM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/1826fe94-f0ce-4f8f-91c0-ba5b4358fb4b)

```
~ % cat subdomains.txt
a.takemeoverforfuns.org
b.takemeoverforfuns.org
1.takemeoverforfuns.org
2.takemeoverforfuns.org
takemyfastly.takemeoverforfuns.org
takemyheroku.takemeoverforfuns.org
github.takemeoverforfuns.org
takemynetlify.takemeoverforfuns.org
```

```
~ % prettydig takemyfastly.takemeoverforfuns.org
takemyfastly.takemeoverforfuns.org. 1799 IN `C-Name` nonssl.global.Fastly.net.
nonssl.global.Fastly.net. 30 IN	A 151.101.0.204
nonssl.global.Fastly.net. 30 IN	A 151.101.64.204
nonssl.global.Fastly.net. 30 IN	A 151.101.128.204
nonssl.global.Fastly.net. 30 IN	A 151.101.192.204
```

![Screenshot 2023-05-22 at 12 06 39 AM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/9a959131-b615-4183-b836-15b7a0954d0f)

```
% curlheaders takemyfastly.takemeoverforfuns.org
HTTP/1.1 500 Service Not Found
Connection: close
Content-Length: 444
Server: Varnish
Retry-After: 0
Content-Type: text/html; charset=utf-8
Accept-Ranges: bytes
Date: Wed, 10 May 2023 03:54:05 GMT
X-Varnish: 2852533752
Via: 1.1 varnish

bin % curlredirect takemyfastly.takemeoverforfuns.org
<html>
<head>
<title>Fastly error: unknown domain takemyfastly.takemeoverforfuns.org</title>
</head>
<body>
<p>Fastly error: unknown domain: takemyfastly.takemeoverforfuns.org. Please check that this domain has been added to a service.</p>
<p>Details: cache-yyc1430024-YYC</p></body></html>%
```

1. Create an account on [Fastly](https://Fastly.com) and setup your domain service - [Guide Here](https://docs.Fastly.com/en/guides/working-with-cname-records-and-your-dns-provider)
2. Log into your account's Fastly Dashboard and click `"Create a Delivery Service”`
3. Enter target subdomain name `(takemyfastly.takemeoverforfuns.org)` and click on `Add`
4. If you encounter the error `(“domain is already taken by another customer”)`, then this implies that configuration has been left on Fastly by the domain/Fastly account owner and it is not subject to takeover in this instance
>   - This is worth monitoring however, as it means the account is still active and likely the service is sitting in a "deactivated" state
>   - - If they delete the account at a later stage but fail to remove the DNS, you may be in luck
>   - If there is no error present, today could be your lucky day and indicate the remote resource the indeed a "dangling domain"
1. Configure a `Host` under `Origins` to effectively forward traffic from the Fastly CDN to your remote PoC (most likely a static IPv4 address of your PoC VM or website)
2. Test hitting the DNS record now and you should see your PoC displayed following the redirect! (Hurrah!) 😹

![Netlify 1](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/ce93e15e-f064-4123-9e5a-c763b7a516d1)

![Netlify 2](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/fa1b2b75-9a3b-433c-9183-88342215af5d)


<br>

## **Subdomain takeover [Example 2]** `Heroku`

- In this example, our recon has lead us to identify the domain `takemeoverforfuns.org` has a subdomain (via `C`-Name record) `takemyheroku.takemeoverforfuns.org` which is pointing to the [Heroku](https://heroku.com) PaaS content provider.

```
~ % httpx -l subdomains.txt -p 80,443,8080,3000 -status-code -title -v

    __    __  __       _  __
   / /_  / /_/ /_____ | |/ /
  / __ \/ __/ __/ __ \|   /
 / / / / /_/ /_/ /_/ /   |
/_/ /_/\__/\__/ .___/_/|_|
             /_/

		projectdiscovery.io

[INF] Current httpx version v1.3.1 (latest)
[DBG] Failed 'http://2.takemeoverforfuns.org:8080': GET http://2.takemeoverforfuns.org:8080 giving up after 1 attempts: Get "http://2.takemeoverforfuns.org:8080": no port found for host
https://takemyheroku.takemeoverforfuns.org [404] [Heroku | Application Error]
[DBG] Failed 'http://2.takemeoverforfuns.org:80': GET http://2.takemeoverforfuns.org:80 giving up after 1 attempts: Get "http://2.takemeoverforfuns.org:80": no port found for host
[DBG] Failed 'http://2.takemeoverforfuns.org:443': GET http://2.takemeoverforfuns.org:443 giving up after 1 attempts: Get "http://2.takemeoverforfuns.org:443": no port found for host
```

- The recon phase has also shown us that we are receiving a `404` HTTP response from the server which could identify a potential dangling domain.

![Screenshot 2023-05-21 at 11 58 15 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/65e7c2e5-9576-4f28-a5d6-8f194248e492)

![Screenshot 2023-05-21 at 11 58 15 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/33c68595-a51c-41a5-b37f-78f94946dfa8)

![Screenshot 2023-05-21 at 11 37 30 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/452c2486-04be-4429-ad98-d60e13dd1014)

```
~ % dig takemyheroku.takemeoverforfuns.org
;; ANSWER SECTION:
takemyheroku.takemeoverforfuns.org. 1799 IN CNAME takemyheroku.herokuapp.com.
takemyheroku.herokuapp.com. 7	IN	A	34.201.81.34
takemyheroku.herokuapp.com. 7	IN	A	54.208.186.182
takemyheroku.herokuapp.com. 7	IN	A	54.224.34.30
takemyheroku.herokuapp.com. 7	IN	A	54.243.129.215
```

- Here is the recursive final `C`-Name record for this subdomain which is pointing to the Heroku DNS which shows a custom DNS record was also added to Heroku.
- This was done so that the DNS record itself will resolve directly to the host application, as well as the custom Heroku-based application DNS record.

```
~ % dig takemyheroku.takemeoverforfuns.org cname
;; ANSWER SECTION:
takemyheroku.takemeoverforfuns.org. 1799 IN CNAME descriptive-thicket-pwucemevmbkjjt449fn6a5ic.herokudns.com.

~ % curlheaders https://takemyheroku.herokuapp.com/
HTTP/1.1 404 Not Found
Connection: keep-alive
Server: Cowboy
Date: Mon, 22 May 2023 05:51:38 GMT
Content-Length: 494
Content-Type: text/html; charset=utf-8
Cache-Control: no-cache, no-store
```

```
~ % curl https://takemyheroku.herokuapp.com/
<!DOCTYPE html>
	<html>
	  <head>
		<meta name="viewport" content="width=device-width, initial-scale=1">
		<meta charset="utf-8">
		<title>No such app</title>
		<style media="screen">
		  html,body,iframe {
			margin: 0;
			padding: 0;
		  }
		  html,body {
			height: 100%;
			overflow: hidden;
		  }
		  iframe {
			width: 100%;
			height: 100%;
			border: 0;
		  }
		</style>
	  </head>
	  <body>
		<iframe src="//www.herokucdn.com/error-pages/no-such-app.html"></iframe>
	  </body>
	</html>%
```

1. Create an account on [Heroku](https://heroku.com)
2. Connect the Heroku app to an existing GitHub repo which represents your PoC or start a new repo and hook up Heroku into the CI
3. Ensure to configure the [`custom domain`](https://devcenter.heroku.com/articles/custom-domains) feature if not activated so that the original domain name is being served to your Heroku content

![Heroku 1](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/9eed2f8c-1e25-44e2-a166-25446f8b46cc)

![Heroku 2](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/86603e05-c062-408c-93bf-f34a67704a8c)

<br>

## **Subdomain takeover [Example 3]** `Netlify`

- The output from `dig` has indicated a `C`-Name record which would be configured such as (within the DNS provider's NS's):
  - **Host**: `takemynetlify`
  - **Value**: `takemynetlify.netlify.app.`

```
~ % dig takemynetlify.takemeoverforfuns.org cname
; <<>> DiG 9.10.6 <<>> takemynetlify.takemeoverforfuns.org cname
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 7055
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;takemynetlify.takemeoverforfuns.org. IN	CNAME

;; ANSWER SECTION:
takemynetlify.takemeoverforfuns.org. 1542 IN CNAME takemynetlify.netlify.app.
```

- The site is not currently alive within Netlify's CDN, is it dangling?

```
~ % curlheaders takemynetlify.takemeoverforfuns.org.
HTTP/1.1 404 Not Found
Cache-Control: private, max-age=0
Content-Type: text/plain; charset=utf-8
Server: Netlify
X-Nf-Request-Id: 01H12WCXMMSX3YK1XB7E0VMHX8
Date: Mon, 22 May 2023 23:23:34 GMT
Content-Length: 50

~ % curlredirect takemynetlify.takemeoverforfuns.org
Not Found - Request ID: 01H12WD4S2V16DQAX89MMK0RE0%
```

```
~ % httpx -u takemynetlify.takemeoverforfuns.org -p 80,443,8080 -status-code -title -v

    __    __  __       _  __
   / /_  / /_/ /_____ | |/ /
  / __ \/ __/ __/ __ \|   /
 / / / / /_/ /_/ /_/ /   |
/_/ /_/\__/\__/ .___/_/|_|
             /_/

		projectdiscovery.io

[INF] Current httpx version v1.3.1 (latest)
https://takemynetlify.takemeoverforfuns.org [404] []
http://takemynetlify.takemeoverforfuns.org [404] []
[DBG] Failed 'http://takemynetlify.takemeoverforfuns.org:8080': GET http://takemynetlify.takemeoverforfuns.org:8080 giving up after 1 attempts: Get "http://takemynetlify.takemeoverforfuns.org:8080": could not connect to any port found for host (Client.Timeout exceeded while awaiting headers)
```

![Screenshot 2023-05-22 at 4 26 15 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/e181e823-027c-4682-8af0-8c9d0450bb0e)

![Screenshot 2023-05-22 at 4 26 59 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/4cd7da76-e7d7-4941-a52a-fd123e55f436)

- At this point, my reaction would be to run `nuclei` with a takeover template to verify if this is exploitable (`% nuclei -u takemynetlify.takemeoverforfuns.org -v -ts -sa -uc -t ~/nuclei-templates/takeovers`).
  - However, for the purpose of this demo, let's roll!

1) Create an account on [`Netlify`](https://app.netlify.com/)
2) Connect your GitHub account via OAUTH 2.0 for workflow identity federation authentication and choose a custom template, or upload your own project from an existing repo
   1) This project will be your PoC in this case, similar to Heroku/GitHub example 2
3) Add a domain under `Domains` > `Domain Management`
4) Enter the subdomain `takemynetlify.takemeoverforfuns.org`
5) Click `Add Subdomain`
6) Await the DNS verification to be completed by Netlify CDN servers which are checking the `C`-Name record is present within DNS and should now display <span style="color:green">green</span>
   1) Ultimately, it's checking the `C`-Name record is present within public DNS which points `takemynetlify.takemeoverforfuns.org` -> (`CNAME`) -> `takemynetlify.netlify.app.` which we found in the earlier recon stage

- The original subdomain eligible for takeover (I.E, the dangling domain `takemynetlify.takemeoverforfuns.org`) now redirects to our Netlify PoC `https://takemynetlify.takemeoverforfuns.org/` **which we control!** (See mine [here](https://github.com/GangGreenTemperTatum/nextjs-blog-theme))

```
bin % curlheaders takemynetlify.takemeoverforfuns.org
HTTP/1.1 301 Moved Permanently
Content-Type: text/plain; charset=utf-8
Location: https://takemynetlify.takemeoverforfuns.org/
Server: Netlify
X-Nf-Request-Id: 01H12XBCS8XMWJ5WVFXBSXWC88
Date: Mon, 22 May 2023 23:40:13 GMT
Content-Length: 59

HTTP/2 200
accept-ranges: bytes
age: 0
cache-control: public, max-age=0, must-revalidate
content-type: text/html; charset=UTF-8
date: Mon, 22 May 2023 23:40:13 GMT
etag: "9167322b6d31059924437fd23009607f-ssl"
server: Netlify
strict-transport-security: max-age=31536000
vary: X-Bb-Conditions
x-nf-request-id: 01H12XBD0E7YNPZT4889YZ571D
content-length: 14098
```

![Screenshot 2023-05-22 at 4 38 40 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/e1b01693-8b78-4c0a-9f27-f516c8b1f647)

![Screenshot 2023-05-22 at 4 42 02 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/750520ae-08a3-478d-8c87-bab6852ab750)

- **For my walkthrough and simplicity sake**, I deployed a random `next.js` blog template to prove subdomain takeover
- However, in the real world:
  - Keep PoC's simple and limit the bells and whistles
  - Remove any sophisticated web design or anything that shows intentionally bad reputational image to the legitimate domain owner/company

7. Test hitting the DNS record now and you should see your PoC displayed following the redirect! (Hurrah!) 😹

![Screen Recording 2023-05-23 at 8 03 03 PM](https://github.com/GangGreenTemperTatum/CTFs/assets/104169244/8643e347-093f-4bd4-a9c0-d93626d046c0)

<br>

💾 EOF
