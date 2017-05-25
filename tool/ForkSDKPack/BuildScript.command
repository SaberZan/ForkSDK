#!/bin/sh

#  BuildScript.command
#  TasksProject
#
#  Created by Andy on 3/23/13.
#  Copyright (c) 2013 Ray Wenderlich. All rights reserved.

#工程路径
#PROJECT_BASE_PATH = $1
##工程文件名
#XCODE_PROJECT_NAME = $2
##工程Target名称
#TARGET_NAME = $3
##生成的IPA名称
#IPA_NAME = $4

cd "${1}"

#XCARCHIVE_NAME = "${3}.xcarchive"

#第一步先编译生成testDemo.xcarchive 文件。 /这里生成的testDemo.xcarchive文件目录与.xcodeproj是同一目录
xcodebuild -archivePath "${3}.xcarchive" -project "${2}" -sdk iphoneos -scheme "${3}" -configuration "Distribution" archive

#第二步把生成的testDemo.xcarchive文件打包成ipa 格式。
xcodebuild -exportArchive -exportFormat IPA -archivePath "${3}.xcarchive" -exportPath "${4}"

rm -rdf "${3}.xcarchive"

echo "** EXPORT SUCCEEDED **"
