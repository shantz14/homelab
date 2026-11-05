## Searching with .lab.home
Pods would append .lab.home to search requests, so something like a request to github.com from 
my personal site would tried as github.com.lab.home before just github.com which unfortunetaly resolves because
I have *.lab.home set to resolve to traefik so it would be sent there instead of github.
### Solution
Adding a resolv.conf to the pods with just
    `namespace 192.168.8.1`
and a kubelet-arg to tell it to look at its own resolv.conf before the node's.
Now it looks at github.com before trying github.com.lab.home.

Maybe I should remove the wildcard and make individual records for personal.lab.home etc
