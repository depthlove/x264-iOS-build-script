#!/bin/sh

CONFIGURE_FLAGS="--enable-static --enable-pic --disable-cli"

# sunminmin blog: http://depthlove.github.io/
# modified by sunminmin, 2015/09/07
ARCHS="arm64 armv7s armv7 x86_64 i386"


# directories
SOURCE="x264"
FAT="x264-iOS"

SCRATCH="scratch-x264"
# must be an absolute path
THIN=`pwd`/"thin-x264"

# the one included in x264 does not work; specify full path to working one
GAS_PREPROCESSOR=/usr/local/bin/gas-preprocessor.pl

COMPILE="y"
LIPO="y"

if [ "$*" ]
then
	if [ "$*" = "lipo" ]
	then
		# skip compile
		COMPILE=
	else
		ARCHS="$*"
		if [ $# -eq 1 ]
		then
			# skip lipo
			LIPO=
		fi
	fi
fi

if [ "$COMPILE" ]
then

# begin: added by sunminmin, 2015/09/07
    if [ ! -r $GAS_PREPROCESSOR ]
    then
    echo 'gas-preprocessor.pl not found. Trying to install...'
    (curl -L https://github.com/libav/gas-preprocessor/blob/master/gas-preprocessor.pl \
    -o /usr/local/bin/gas-preprocessor.pl \
    && chmod +x /usr/local/bin/gas-preprocessor.pl) \
    || exit 1
    fi


    if [ ! -r $SOURCE ]
    then
    echo 'x264 source not found. Trying to download...'
    curl https://download.videolan.org/pub/x264/snapshots/x264-snapshot-20140930-2245.tar.bz2 | tar xj && ln -s x264-snapshot-20140930-2245 x264 || exit 1
    fi
# end: added by sunminmin, 2015/09/07

	CWD=`pwd`
	for ARCH in $ARCHS
	do
		echo "building $ARCH..."
		mkdir -p "$SCRATCH/$ARCH"
		cd "$SCRATCH/$ARCH"

		CFLAGS="-arch $ARCH"
		ASFLAGS=

		if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
		then
		    PLATFORM="iPhoneSimulator"
		    CPU=
		    if [ "$ARCH" = "x86_64" ]
		    then
		    	CFLAGS="$CFLAGS -mios-simulator-version-min=7.0"
		    	HOST=
		    else
		    	CFLAGS="$CFLAGS -mios-simulator-version-min=5.0"
			HOST="--host=i386-apple-darwin"
		    fi
		else
		    PLATFORM="iPhoneOS"
		    if [ $ARCH = "arm64" ]
		    then
		        HOST="--host=aarch64-apple-darwin"
				XARCH="-arch aarch64"
		    else
		        HOST="--host=arm-apple-darwin"
				XARCH="-arch arm"
		    fi

			CFLAGS="$CFLAGS -fembed-bitcode -mios-version-min=7.0"
			ASFLAGS="$CFLAGS"
		fi

		XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
		CC="xcrun -sdk $XCRUN_SDK clang"
		if [ $PLATFORM = "iPhoneOS" ]
		then
		    export AS="$GAS_PREPROCESSOR $XARCH -- $CC"
		else
		    export -n AS
		fi

		CXXFLAGS="$CFLAGS"
		LDFLAGS="$CFLAGS"

		CC=$CC $CWD/$SOURCE/configure \
		    $CONFIGURE_FLAGS \
		    $HOST \
		    --extra-cflags="$CFLAGS" \
			--extra-asflags="$ASFLAGS" \
		    --extra-ldflags="$LDFLAGS" \
		    --prefix="$THIN/$ARCH"

		make -j3 install
		cd $CWD
	done
fi

if [ "$LIPO" ]
then
	echo "building fat binaries..."
	mkdir -p $FAT/lib
	set - $ARCHS
	CWD=`pwd`
	cd $THIN/$1/lib
	for LIB in *.a
	do
		cd $CWD
		lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB
	done

	cd $CWD
	cp -rf $THIN/$1/include $FAT
fi

# begin: added by sunminmin, 2015/09/07
echo "copy config.h to ..."
for ARCH in $ARCHS
do
cd $CWD
echo "copy $SCRATCH/$ARCH/config.h to $THIN/$ARCH/$include"
cp -rf $SCRATCH/$ARCH/config.h $THIN/$ARCH/$include || exit 1
done

echo "building success!"
# end: added by sunminmin, 2015/09/07

echo Done


