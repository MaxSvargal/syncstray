#!/bin/bash

RELEASES_PATH="./builds/releases"
WIN_PATH="${RELEASES_PATH}/syncstray/win/SyncStray"
OSX_PATH="${RELEASES_PATH}/syncstray/mac"
LIN64_PATH="${RELEASES_PATH}/syncstray/linux64/SyncStray"
LIN32_PATH="${RELEASES_PATH}/syncstray/linux32/SyncStray"

mkdir ${RELEASES_PATH}/$1

mkdir ${RELEASES_PATH}/$1/win
zip -j -X ${RELEASES_PATH}/$1/win/syncstray.zip "${WIN_PATH}/icudt.dll" "${WIN_PATH}/icudt.dll" "${WIN_PATH}/nw.pak" "${WIN_PATH}/SyncStray.exe"
echo "Archive for Windows created."

mkdir ${RELEASES_PATH}/$1/osx
cd ${OSX_PATH}
zip -X -r ../../$1/osx/syncstray.zip "SyncStray.app"
cd ../../../../
echo "Archive for OS X created."

mkdir ${RELEASES_PATH}/$1/linux32
zip -j -X ${RELEASES_PATH}/$1/linux32/syncstray.zip "${LIN32_PATH}/nw.pak" "${LIN32_PATH}/SyncStray"
echo "Archive for Linux x32 created."

mkdir ${RELEASES_PATH}/$1/linux64
zip -j -X ${RELEASES_PATH}/$1/linux64/syncstray.zip "${LIN64_PATH}/nw.pak" "${LIN64_PATH}/SyncStray"
echo "Archive for Linux x64 created."