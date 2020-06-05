[![Build Trigger Status](https://ci.ziggzagg.fr/api/badges/zaggash/docker-makepkg/status.svg)](https://ci.ziggzagg.fr/zaggash/docker-makepkg)

## docker-makepkg

This Docker image is used to create Archlinux packages through Docker.  
It is usefull to buil local packages and also to easily build in CI.


### Usage locally:  


```
docker run -e EXPORT_PKG=true -e CHECKSUM_SRC=true -e PGPKEY="$PGP_KEY" -v "$(pwd):/pkg" zaggash/arch-makepkg
```

Where:  
```
-v "$(pwd):/pkg"             | bind mount a local folder to the container working dir.  

-e EXPORT_PKG=true/false     | Used to export build package to the mounted folder  
-e CHECKSUM_SRC=true/false   | Used to verify checksum from the downloaded source and not from the PKGBUILD hash  
-e PGPKEY="$PGP_KEY"         | Used to sign the package with $PGP_KEY, $PGP_KEY should be encoded in base64  
                             |
                             | PGP_KEY=$(base64 /path/to/key.pgp)
```
