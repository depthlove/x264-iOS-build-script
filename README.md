# x264 iOS build script

**My blog: [http://depthlove.github.io/](http://depthlove.github.io/)**

This is a shell script to build x264 for iOS apps.

Tested with:

* x264-snapshot-20140914-2245
* Xcode 6.4

## Requirements

* https://github.com/libav/gas-preprocessor

## Usage

* To build everything:

        ./build-x264.sh

* To build for arm64:

        ./build-x264.sh arm64

* To build fat library for armv7 and x86_64 (64-bit simulator):

        ./build-x264.sh armv7 x86_64

* To build fat library from separately built thin libraries:

        ./build-x264.sh lipo

#### about x264 encode video streaming to h264, you can watch my paper [http://depthlove.github.io/2015/09/17/use-x264-encode-iOS-camera-video-to-h264/](http://depthlove.github.io/2015/09/17/use-x264-encode-iOS-camera-video-to-h264/)

##### 关于x264编码视频流为h264的内容，可以参看我的文章：[http://depthlove.github.io/2015/09/17/use-x264-encode-iOS-camera-video-to-h264/](http://depthlove.github.io/2015/09/17/use-x264-encode-iOS-camera-video-to-h264/)

##### 更多内容可参看我的github博客：http://depthlove.github.io/
