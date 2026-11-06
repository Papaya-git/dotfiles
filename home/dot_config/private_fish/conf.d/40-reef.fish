# reef (Homebrew, tap zstud/reef): runs bash commands pasted into fish.
# Transparent mode: reef shows the fish translation (or "via bash") and waits for [Y/n]
# before running it. To turn it off: reef confirm off
# Must be set before reef's vendor_conf.d, which only sets its defaults when nothing is defined.
set -g reef_confirm true
