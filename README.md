# rv1106-system patch branch

The full `rv1106-system` repository is too large to seed into `git.agnt.sh`
from this checkout over HTTPS. The remote rejected that push with HTTP 413.

This branch preserves the change as a `git format-patch` file that can be
applied on top of `jetkvm/rv1106-system` `dev`.

Apply with:

```bash
git am 0001-Install-dnsmasq-for-USB-network-support.patch
```
