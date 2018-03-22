# DN_ISO_Generator
This repository generates the .iso file for installing DappNode to a server. Below are the instructions that you will need to make your own DappNode ISO. We have provided a script to automatically detect your Operating System and install the dependencies for you on a supported Operating System. The tested OS are: MacOS X, Fedora, and Ubuntu. 

# Tips
Docker and docker-compose should not be run with 'sudo', therefore it is necessary to install them with the correct permissions. In linux this should be done with
```
$ sudo usermod -aG docker $USER 
```

With MacOS X, this should be done by installing docker and docker-compose via brew with
```
$ brew install docker docker-compose
```

# Currently supported Operating Systems
RPM based linux
DEB based linux
MacOS X

# Dependencies

## Linux

[docker](https://docs.docker.com/engine/installation)

[docker-compose](https://docs.docker.com/compose/install/)

[xorriso](https://www.gnu.org/software/xorriso/)

[xz](https://tukaani.org/xz/)


## MacOS 

[brew](https://brew.sh/index_es.html) 

[docker](https://docs.docker.com/engine/installation) (Recommended via brew install docker")

[docker-compose](https://docs.docker.com/compose/install/) (Recommended via "brew install docker-compose")

[Xcode](https://itunes.apple.com/us/app/xcode/id497799835)

[xorriso MacOS X](http://macappstore.org/xorriso/)

[xz MacOS X](http://macappstore.org/xz/)



# Repository installation

```
$ git clone --recursive https://github.com/dappnode/DN_ISO_Generator.git
```

```
$ cd DN_ISO_Generator
```

```
$ sudo sh ./install_depend.sh
```


# Generation of ISO image

# Prerequisites

[docker](https://docs.docker.com/engine/installation)

[brew](https://brew.sh/index_es.html) (MacOS X)

[xorriso MacOS X](http://macappstore.org/xorriso/)

[xorriso Ubuntu](https://packages.ubuntu.com/xenial/xorriso)

[xz MacOS X](http://macappstore.org/xz/)

[xz Ubuntu](https://packages.ubuntu.com/xenial/xz-utils)

# Installation
```
git clone --recurse-submodules https://github.com/dappnode/DN_ISO_Generator.git
```

# Generation of ISO image
```
./generate_ISO.sh
```
