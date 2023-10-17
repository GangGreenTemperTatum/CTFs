### One-liner for subdomain recon and jacking using `subfinder` and `subjack`:

`subfinder -d company.ai -o company-$(date +%Y%m%d_%H%M).ai.txt ; subjack -w company-$(date +%Y%m%d_%H%M).ai.txt -t 100 -timeout 30 -ssl -c /Users/adam/go/src/github.com/haccer/subjack/fingerprints.json -v 3`
