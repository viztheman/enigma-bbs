#!/bin/bash
trap '' 2
# $1 Node number
# $2 Door Call Name
stty cols 80 rows 25

BBSROOT=/home/chokes/enigma-bbs
NODE=$BBSROOT/drop/node$1

# Convert DOOR.SYS to DOS line endings
unix2dos $NODE/DOOR.SYS 2>/dev/null

# Define root directory for DOSEMU hdd
DROOT=/home/chokes/.dosemu/drive_c/nodes/temp$1
mkdir -p "$DROOT"

# Define node directory inside DOSEMU filesystem
cp $NODE/DOOR.SYS $DROOT/DOOR.SYS

# Generate a random lowercase 4 digit code for batch file uniqueness
RAND=$(tr -dc a-f0-9 2>/dev/null  </dev/urandom | head -c 4)

FILE=RUN$RAND.BAT

# Convert to lowercase for linux
DOOR=$(echo "$2" | tr '[:upper:]' '[:lower:]')

run_batch(){
    # Arg 1 = NODE
    # Arg 2 = FILE (batch filename)
    # Arg 3 = DROOT (dosemu node folder)
    nice -n 19 /usr/bin/dosemu -E "C:\\NODES\\TEMP$1\\$2" 1>/dev/null 2>&1
    rm $3/$2
    rm $3/DOOR.SYS
}

case "$DOOR" in
    lord)
        echo -e '\r@echo off \r' > $DROOT/$FILE
        echo -e 'c: \r' >> $DROOT/$FILE
	echo -e 'cd c:\\bnu \r' >> $DROOT/$FILE
	echo -e 'bnu.com \r' >> $DROOT/$FILE
        echo -e 'cd c:\\doors\\lord\\ \r' >> $DROOT/$FILE
        echo -e 'start.bat '$1' \r' >> $DROOT/$FILE
        echo -e 'exitemu' >> $DROOT/$FILE
        unix2dos $DROOT/$FILE 2>/dev/null
        run_batch $1 $FILE $DROOT
        ;;
    usurper)
        echo -e '\r@echo off \r' > $DROOT/$FILE
        echo -e 'c: \r' >> $DROOT/$FILE
        echo -e 'cd c:\\doors\\usurper\\ \r' >> $DROOT/$FILE
        echo -e 'usurper /N'$1' /Pc:\\nodes\\temp'$1' \r' >> $DROOT/$FILE
        echo -e 'exitemu' >> $DROOT/$FILE
        unix2dos $DROOT/$FILE 2>/dev/null
        run_batch $1 $FILE $DROOT
        ;;
    tw2002)
        echo -e '\r@echo off \r' > $DROOT/$FILE
	echo -e 'SET RTM=EXTMAX 1024 \r' >> $DROOT/$FILE
        echo -e 'c: \r' >> $DROOT/$FILE
        echo -e 'cd c:\\doors\\tw2002 \r' >> $DROOT/$FILE
        echo -e 'CALL tw2002 TWNODE='$1' NOXMS NOEMS BUFFER=16500 MULTITASK=YES' >> $DROOT/$FILE
        echo -e 'exitemu' >> $DROOT/$FILE
        unix2dos $DROOT/$FILE 2>/dev/null
        run_batch $1 $FILE $DROOT
        ;;

    *)
        echo "Invalid option"
        ;;
esac
trap 2
