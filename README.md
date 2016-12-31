# mineos-docker
Dockerfiles for MineOS Images

Docker instances must be opened

* USER_NAME=mc (optional)
* USER_PASSWORD=mypass (required)
* ACCEPT_ORACLE_LICENSE= (required for CRUX image only)

CRUX:

    docker run -itd -p 8443:8443 -p 25565:25565 -e USER_PASSWORD=mypass -e ACCEPT_ORACLE_LICENSE=true -v /var/games/minecraft:/var/games/minecraft hexparrot/mineos:node-crux

Debian "Jessie":

    docker run -itd -p 8443:8443 -p 25565:25565 -e USER_PASSWORD=mypass -v /var/games/minecraft:/var/games/minecraft hexparrot/mineos:node-jessie

Ubuntu "Vivid":

    docker run -itd -p 8443:8443 -p 25565:25565 -e USER_PASSWORD=mypass -v /var/games/minecraft:/var/games/minecraft hexparrot/mineos:node-vivid

Ubuntu "Wily":

    docker run -itd -p 8443:8443 -p 25565:25565 -e USER_PASSWORD=mypass -v /var/games/minecraft:/var/games/minecraft hexparrot/mineos:node-wily

Full Format Example

    docker run -itd -p 8443:8443 -p 25565:25565 -e USER_NAME=will -e USER_PASSWORD=pass123 -e ACCEPT_ORACLE_LICENSE=true -v /var/games/minecraft:/var/games/minecraft hexparrot/mineos:node-crux
