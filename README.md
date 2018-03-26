# DN_ISO_Generator
This repository generates the .iso file for installing DappNode to a server. Below are the instructions that you will need to make your own DappNode ISO.

# Prerequisites

- git

   Install [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) commandline tool.

- docker

   Install [docker](https://docs.docker.com/engine/installation). The community edition (docker-ce) will work. In Linux make sure you grant permissions to the current user to use docker by adding current user to docker group, `sudo usermod -aG docker $USER`. Once you update the users group, exit from the current terminal and open a new one to make effect.

- docker-compose

   Install [docker-compose](https://docs.docker.com/compose/install)
   
**Note**: Make sure you can run `git`, `docker ps`, `docker-compose` without any issue and without sudo command.

# Generation of ISO image

```
$ git clone --recursive https://github.com/dappnode/DN_ISO_Generator.git
$ cd DN_ISO_Generator
$ docker-compose up
```

When the execution of the Docker-compose finishes you can find the iso image of DAppNode in the images folder:
```
$ ls -lrt images/DappNode-ubuntu-16.04.3-server-amd64.iso
-rw-r--r--  1 edu  staff  916455424 26 mar 13:19 images/DappNode-ubuntu-16.04.3-server-amd64.iso
```

## Contributing

Please read [CONTRIBUTING.md](https://github.com/dappnode) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/dappnode/DNP_IPFS/tags). 

## Authors

* **Eduardo Antuña Díez** - *Initial work* - [eduadiez](https://github.com/eduadiez)

See also the list of [contributors](https://github.com/dappnode/DNP_IPFS/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## References

[git](https://git-scm.com/)

[docker](https://www.docker.com/)

[docker-compose](https://docs.docker.com/compose/)