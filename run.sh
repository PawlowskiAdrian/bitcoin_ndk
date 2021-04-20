#! /bin/bash
set -xeo pipefail

DOCKERHASH=06e3e394f41bd389a11ce51a2bb4ec46ff082e86d25f4f90644aad5b4faaf0f1
DOCKERIMAGE=greenaddress/core_builder_for_android@sha256:$DOCKERHASH
docker pull $DOCKERIMAGE

ARCHS="armv7a-linux-androideabi=32 aarch64-linux-android=64 x86_64-linux-android=64 i686-linux-android=32"

build_repo() {
    for TARGETHOST in $ARCHS; do
        docker run -v $PWD:/repo $DOCKERIMAGE /bin/bash -c "/repo/fetchbuild.sh $1 $2 $3 $4 $5 ${TARGETHOST/=/ }" &
    done
}

build_repo https://github.com/PawlowskiAdrian/bitcoin.git 297c9ec85688c3a7c7bf13249b2a80253c750092 PawlowskiAdrian bitcoin --disable-man

wait

echo "DONE"

printpackages() {
    echo
    for f in $(find . -type f -name "*$1.tar.xz" | sort)
    do
        shahash=$(sha256sum $f | cut -d" " -f1)
        filesize=$(ls -lat $f | cut -d" " -f5)
        arch=${f/.\//}
        arch=${arch/$1.tar.xz/}
        echo \"${filesize}${arch}${shahash}\",
    done
    echo
}

set +x
printpackages _bitcoin
