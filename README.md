# DAppNode_Installer 

[![Website dappnode.io](https://img.shields.io/badge/Website-dappnode.io-brightgreen.svg)](https://dappnode.io/)
[![Documentation Wiki](https://img.shields.io/badge/Documentation-Wiki-brightgreen.svg)](https://github.com/dappnode/DAppNode/wiki)
[![GIVETH Campaign](https://img.shields.io/badge/GIVETH-Campaign-1e083c.svg)](https://beta.giveth.io/campaigns/5b44b198647f33526e67c262)
[![RIOT DAppNode](https://img.shields.io/badge/RIOT-DAppNode-blue.svg)](https://riot.im/app/#/room/#DAppNode:matrix.org)
[![Twitter Follow](https://img.shields.io/twitter/follow/espadrine.svg?style=social&label=Follow)](https://twitter.com/DAppNODE?lang=es)

This repository generates the .iso file for installing DappNode to a server. Below are the instructions that you will need to make your own DappNode ISO.

Follow this link if you want to know how to install DAppNode: [DappNode-Installation-Guide](https://github.com/dappnode/Dappnode/wiki/DappNode-Installation-Guide)

# How to generate a DAppNode's ISO
## Prerequisites
Make sure the following sotfware is installed

### 1. git
Run this command to verify the git:
```
$ git --version
```
If you don't see a valid version, install [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) commandline tool.

### 2. docker
Run this command to verify the git:
```
$ docker -v
```
If you don't see a valid version, install [docker](https://docs.docker.com/engine/installation). The community edition (docker-ce) will work. In Linux make sure you grant permissions to the current user to use docker by adding current user to docker group, `sudo usermod -aG docker $USER`. Once you update the users group, exit from the current terminal and open a new one to make effect.

### 3. docker-compose
Run this command to verify the git:
```
$ docker-compose -v
```
If you don't see a valid version, install [docker-compose](https://docs.docker.com/compose/install)
   
**Note**: Make sure you can run `git`, `docker ps`, `docker-compose` without any issue and without sudo command.

# Generate the ISO image

### 1. Generate DAppNode's ISO
Run the following commands in your terminal. Make sure you have at least 2 GB of disk space available.
```
$ git clone https://github.com/dappnode/DAppNode_Installer.git
$ cd DAppNode_Installer
$ docker-compose build
$ docker-compose up
```

### 2. Verify image generation
When the execution of the Docker-compose finishes, run the following command to verify the image existance:
```
$ ls -lrt images/DappNode-ubuntu-*
-rw-r--r--  1 edu  staff  916455424 20 mar 13:19 images/DAppNode-ubuntu-18.04-server-amd64.iso
```

### 3. Burn the ISO into a USB
Now you can burn the ISO to a DVD or create a bootable USB. Follow the tutorial of your operating system below and come back when you are finished:

* [MacOS](https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-macos)
* [Windows](https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-windows)
* [Ubuntu](https://tutorials.ubuntu.com/tutorial/tutorial-create-a-usb-stick-on-ubuntu)

Once completed, come back to the [main guide to install an Ubuntu server](https://github.com/dappnode/DAppNode/wiki/DAppNode-Installation-Guide#13-install-an-ubuntu-distribution).


## Contributing

Please read [CONTRIBUTING.md](https://github.com/dappnode) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/dappnode/DAppNode_Installer/tags). 

## Authors

* **Eduardo Antuña Díez** - *Initial work* - [eduadiez](https://github.com/eduadiez)

See also the list of [contributors](https://github.com/dappnode/DAppNode_Installer/contributors) who participated in this project.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details

## References

[git](https://git-scm.com/)

[docker](https://www.docker.com/)

[docker-compose](https://docs.docker.com/compose/)
