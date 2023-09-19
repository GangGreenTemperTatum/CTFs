# OWASP Juice Shop | Web Application | Walkthrough | Ads Dawson | September 2023

# 😇😇 **###### DISCLAIMER ######** *Spoilers below!* 😇😇

## 👷🚧 **********************This writeup is a continuous work in progress********************** 👷🚧

# [Juice Shop (OWASP Project)](https://owasp.org/www-project-juice-shop/) Walkthrough Writeup

[@GangGreenTemperTatum](https://github.com/GangGreenTemperTatum)

Postman Collection or local `openapi.json` spec

GitHub Repo

**v1.0, 09-16-2023**

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

## Setup your local Juice Shop environment: 🥤

1. Run `docker pull bkimminich/juice-shop`
2. Run `docker run --rm -p 3000:3000 bkimminich/juice-shop`
    1. Verify with `docker ps -a`
3. Browse to [http://localhost:3000](http://localhost:3000/) (aave this as your Postman `baseURl` variable)

Access via [`http://localhost:8888/login`](http://localhost:8888/login) - 

Set your Burp Suite scope to ****Advanced**** and enter: (drop out of scope requests)

```markdown
Host: ^localhost\.*$
Port: ^3000$
File: ^/.*

Host: ^localhost\.*$
Port: ^8025$
File: ^/.*

etc.
```

I also recommend creating a new Postman `Environment` and linking variables from subsequent requests for a smoother experience.

# [Challenges](https://owasp.org/www-project-juice-shop/): 🧃

## Scoreboard - Flag 😈

When performing hAPI path of the application, I found a backend REST API call being made to the challenge board (which makes sense if it’s a tracked progress scheme) but is failing due to `401` client unauthorized.

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled.png)

Therefore, I created an account and re-tried, voila!

Following account creation, we now have a valid JWT token for authentication but the API is looking for a specific format/headers:

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%201.png)

Using `devtools`, I inspected hidden elements and found `main.js` which container a hint for the URL: (`localhost:3000/#/score-board`)

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%202.png)

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%203.png)

## **Access the administration section of the store** - Flag 😈

Fortunately, `devtools` to the rescue again here:

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%204.png)

The `/login` as instructed is deemed vulnerable to iSQL after testing an initial set of quotations into the field:

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%205.png)

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%206.png)

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%207.png)

We now have the admin user’s username (`admin@juice-sh.op`) and password hash (`0192023a7bbd73250516f069df18b500`)

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%208.png)

## Bonus Payload ****- Flag 😈

An inline frame (iframe) is **a HTML element that loads another HTML page within the document**. It essentially puts another webpage within the parent page.

```markdown
<iframe width="100%" height="166" scrolling="no" frameborder="no" allow="autoplay" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/771984076&color=%23ff5500&auto_play=true&hide_related=false&show_comments=true&show_user=true&show_reposts=false&show_teaser=true"></iframe>
```

Straight away, our `#/search?q=` URL is an input or sink we can test, let’s test and confirm:

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%209.png)

The `iframe` from SoundCloud is being loaded as the application fails from preventing us writing malicious data to the HTML within the search functionality.

## Bully Chatbot ****- Flag 😈

The Chatbot endpoint at `POST /rest/chatbot/` doesn’t look to have any rate-limiting protection:

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%2010.png)

Clicking through repeated requesters in the Repeater, we can see that the response changes until submission:

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%2011.png)

## Confidential Document

Perhaps there’s something in this hidden ftp directory which came back in the scan results?

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%2012.png)

This came back in the scan from the 

![Untitled](OWASP%20Juice%20Shop%20Web%20Application%20Walkthrough%20Ads%20D%20a5192ca1c52748fcbd088fac3b8efb9e/Untitled%2013.png)