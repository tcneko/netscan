### Netscan



Scan multiple network periodically and display scan results in CLI



#### Install & Use



This shell script only tested in ubuntu, but should be able to work in other environments.

```bash
# install require software
apt install -y jq bc fping socat

# clone the code
cd ${path_to_install}
git clone https://github.com/tcneko/netscan.git

# edit the configuration file
cd netsacn
cp netscan_example.json netscan.json
vim netscan.json # add network you want to sacn

# run
sudo bash netscan.sh
```

