### One-liner for subdomain recon and jacking using `subfinder` and `subjack`:

`subfinder -d company.ai -o company-$(date +%Y%m%d_%H%M).ai.txt ; subjack -w company-$(date +%Y%m%d_%H%M).ai.txt -t 100 -timeout 30 -ssl -c /Users/adam/go/src/github.com/haccer/subjack/fingerprints.json -v 3`

### One-liner to search for sub-domains vulnerable to jacking, then run `httprobe` on them whilst outputting the results to the termina; as well as writing to a file

[VIM tutorial: linux terminal tools for bug bounty pentest and redteams with @tomnomnom](https://www.youtube.com/watch?v=l8iXMgk2nnY&t=3s) is AWESOME

https://github.com/tomnomnom/meg

`assetfinder --subs-only company.com > domains.txt`

`cat domains.txt | httprobe | tee -a hosts.txt`

Search for asset path discovery:

`meg -d 1000 -v /`

Take input and open it in the buffer:

`grep -Hnru "domain" | vim -`

Take current file and run it through a shell process to remove CSPs:

`:%!grep -v Content-Security`

Use the `gf` command to find flags given to grep outputs:

https://github.com/tomnomnom/gf

`cat -/.gf/aws-keys.json`

`:%!awk -F':' '{print $3}'`

VIM's vertical-block mode = `-v`

