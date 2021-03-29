# Netscan

Scan multiple network periodically and display scan results in CLI

## Install & Use

This shell script only tested in ubuntu, but should be able to work in other environments.

```
apt install -y nmap jq
cd ${path_to_install}
git clone https://github.com/tcneko/netscan.git
cd netsacn
mkfifo netscan_fifo_pipe
cp netscan_example.json netscan.json
vim netscan.json // add network you want to sacn
bash netscan.sh
```