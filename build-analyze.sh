#!/bin/bash

# Configuration for SonarCloud
SONAR_HOST_URL=https://sonarcloud.io
#SONAR_TOKEN= # access token from SonarCloud projet creation page -Dsonar.login=XXXX: define in the environement through the CI
export SONAR_SCANNER_VERSION="4.6.1.2450" # Find the latest version in the "Windows" link on this page:
                                          # https://sonarcloud.io/documentation/analysis/scan/sonarscanner/
export BUILD_WRAPPER_OUT_DIR="build_wrapper_output_directory" # Directory where build-wrapper output will be placed

mkdir $HOME/.sonar
export SONAR_SCANNER_HOME=$HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-macosx

# Download build-wrapper
curl -sSLo $HOME/.sonar/build-wrapper-macosx-x86.zip https://sonarcloud.io/static/cpp/build-wrapper-macosx-x86.zip
unzip -o $HOME/.sonar/build-wrapper-macosx-x86.zip -d $HOME/.sonar/
export PATH=$HOME/.sonar/build-wrapper-macosx-x86:$PATH

# Download sonar-scanner
curl -sSLo $HOME/.sonar/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-macosx.zip 
unzip -o $HOME/.sonar/sonar-scanner.zip -d $HOME/.sonar/
export PATH=$SONAR_SCANNER_HOME/bin:$PATH
export SONAR_SCANNER_OPTS="-server"

# Setup the build system
xcodebuild -project macos-xcode.xcodeproj clean

# Build inside the build-wrapper
build-wrapper-macosx-x86 --out-dir $BUILD_WRAPPER_OUT_DIR xcodebuild -project macos-xcode.xcodeproj -configuration Release

# Run sonar scanner
sonar-scanner -Dsonar.host.url="${SONAR_HOST_URL}" -Dsonar.login=$SONAR_TOKEN -Dsonar.cfamily.build-wrapper-output=$BUILD_WRAPPER_OUT_DIR
