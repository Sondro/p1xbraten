#!/bin/sh
# SAUER_DIR should refer to the directory in which Sauerbraten data files are placed.
#SAUER_DIR=~/sauerbraten
if [ -z ${SAUER_DIR} ]
then
  if [ -x ~/sauerbraten-code ]
  then
    SAUER_DIR=~/sauerbraten-code
  else
    echo "SAUER_DIR not set and ~/sauerbraten-code does not exist"
    exit 1
  fi
fi

# SAUER_BIN should refer to the directory in which Sauerbraten executable files are placed.
SAUER_BIN=./bin_unix

# SAUER_OPTIONS contains any command line options you would like to start Sauerbraten with.
#SAUER_OPTIONS="-f"
SAUER_OPTIONS="-q${HOME}/.p1xbraten -k${SAUER_DIR}"

# SYSTEM_NAME should be set to the name of your operating system.
#SYSTEM_NAME=Linux
SYSTEM_NAME=`uname -s`

# MACHINE_NAME should be set to the name of your processor.
#MACHINE_NAME=i686
MACHINE_NAME=`uname -m`

case ${SYSTEM_NAME} in
Linux)
  SYSTEM_NAME=linux_
  ;;
*)
  SYSTEM_NAME=unknown_
  ;;
esac

case ${MACHINE_NAME} in
i486|i586|i686)
  MACHINE_NAME=
  ;;
x86_64|amd64)
  MACHINE_NAME=64_
  ;;
*)
  if [ ${SYSTEM_NAME} != native_ ]
  then
    SYSTEM_NAME=native_
  fi
  MACHINE_NAME=
  ;;
esac

if [ -x ${SAUER_BIN}/native_client ]
then
  SYSTEM_NAME=native_
  MACHINE_NAME=
fi

if [ ${XDG_SESSION_TYPE} == wayland ]
then
  export SDL_VIDEODRIVER=wayland
fi

if [ -x ${SAUER_BIN}/${SYSTEM_NAME}${MACHINE_NAME}client ]
then
  #exec gdb --args ${SAUER_BIN}/${SYSTEM_NAME}${MACHINE_NAME}client ${SAUER_OPTIONS} "$@"
  exec ${SAUER_BIN}/${SYSTEM_NAME}${MACHINE_NAME}client ${SAUER_OPTIONS} "$@"
else
  echo "Your platform does not have a pre-compiled Sauerbraten client."
  echo "Please follow the following steps to build a native client:"
  echo "1) Ensure you have the SDL2, SDL2-image, SDL2-mixer, and OpenGL libraries installed."
  echo "2) Change directory to src/ and type \"make install\"."
  echo "3) If the build succeeds, return to this directory and run this script again."
  exit 1
fi

