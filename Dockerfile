FROM ubuntu:16.10

ENV ANDROID_HOME /opt/android-sdk-linux

# ------------------------------------------------------
# --- Install required tools
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends openjdk-8-jdk wget maven ruby expect && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------
# --- Download Android SDK tools into $ANDROID_HOME

RUN cd /opt && wget -q https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz -O android-sdk.tgz \
 && cd /opt && tar -xvzf android-sdk.tgz \
 && cd /opt && rm -f android-sdk.tgz

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# ------------------------------------------------------
# --- Install Android SDKs and other build packages
# Other tools and resources of Android SDK
#  you should only install the packages you need!
# To get a full list of available options you can use:
#  android list sdk --no-ui --all --extended
# (!!!) Only install one package at a time, as "echo y" will only work for one license!
#       If you don't do it this way you might get "Unknown response" in the logs,
#         but the android SDK tool **won't** fail, it'll just **NOT** install the package.

RUN echo y | android update sdk --no-ui --all --filter platform-tools | grep 'package installed'

#RUN echo y | android update sdk --no-ui --all --filter extra-android-support | grep 'package installed'


# SDKs
# Please keep these in descending order!

RUN echo y | android update sdk --no-ui --all --filter android-25 | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter android-24 | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter android-23 | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter android-18 | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter android-16 | grep 'package installed'



# build tools
# Please keep these in descending order!

RUN echo y | android update sdk --no-ui --all --filter build-tools-25.0.2 | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter build-tools-25.0.1 | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter build-tools-25.0.0 | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter build-tools-24.0.3 | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter build-tools-24.0.2 | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter build-tools-24.0.1 | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter build-tools-23.0.3 | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter build-tools-23.0.2 | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter build-tools-23.0.1 | grep 'package installed'



# Android System Images, for emulators

# Please keep these in descending order!

#RUN echo y | android update sdk --no-ui --all --filter sys-img-x86_64-android-25 | grep 'package installed'

#RUN echo y | android update sdk --no-ui --all --filter sys-img-x86-android-25 | grep 'package installed'

#RUN echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-25 | grep 'package installed'



#RUN echo y | android update sdk --no-ui --all --filter sys-img-x86_64-android-24 | grep 'package installed'

#RUN echo y | android update sdk --no-ui --all --filter sys-img-x86-android-24 | grep 'package installed'

#RUN echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-24 | grep 'package installed'



#RUN echo y | android update sdk --no-ui --all --filter sys-img-x86-android-23 | grep 'package installed'

#RUN echo y | android update sdk --no-ui --all --filter sys-img-armeabi-v7a-android-23 | grep 'package installed'



# Extras

RUN echo y | android update sdk --no-ui --all --filter extra-android-m2repository | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter extra-google-m2repository | grep 'package installed'

RUN echo y | android update sdk --no-ui --all --filter extra-google-google_play_services | grep 'package installed'



# install those?



# build-tools-21.0.0

#build-tools-21.0.1

#build-tools-21.0.2

#build-tools-21.1.0

#build-tools-21.1.1

#build-tools-21.1.2

#build-tools-22.0.0

#build-tools-22.0.1

#build-tools-23.0.0

#build-tools-23.0.1

#build-tools-23.0.2

#build-tools-23.0.3

#build-tools-24.0.0

#build-tools-24.0.1

#build-tools-24.0.2

#android-21

#android-22

#android-23

#android-24

#addon-google_apis-google-24

#addon-google_apis-google-23
#addon-google_apis-google-22

#addon-google_apis-google-21
 
#extra-android-support

#extra-android-m2repository

#extra-google-m2repository

#extra-google-google_play_services

#sys-img-arm64-v8a-android-24

#sys-img-armeabi-v7a-android-24

#sys-img-x86_64-android-24

#sys-img-x86-android-24



# google apis

# Please keep these in descending order!

RUN echo y | android update sdk --no-ui --all --filter addon-google_apis-google-23 | grep 'package installed'


# Copy install tools
COPY tools /opt/tools


#Copy accepted android licenses
COPY licenses ${ANDROID_HOME}/licenses
RUN chmod 755 /opt/tools/android-accept-licenses.sh

ENV PATH ${PATH}:/opt/tools

# Update SDK

RUN /opt/tools/android-accept-licenses.sh android update sdk --no-ui --obsolete --force

RUN chown -R 1000:1000 $ANDROID_HOME

#VOLUME ["/opt/android-sdk-linux"]



# Download robolectric
RUN \
  mkdir -p /usr/local/src/robolectric && cd /usr/local/src/robolectric && \
  wget https://github.com/robolectric/robolectric/archive/robolectric-3.3.2.tar.gz -qO - | tar -xz && \
  rm -rf robolectric-3.3.2.tar.gz

# Compile robolectric
RUN cd /usr/local/src/robolectric/robolectric-robolectric-3.3.2/scripts && ./install-dependencies.rb
RUN cd /usr/local/src/robolectric/robolectric-robolectric-3.3.2 && ./gradlew clean assemble install compileTest && \
    cd /usr/local/src/robolectric/robolectric-robolectric-3.3.2 && ./gradlew clean 

#WORKDIR /usr/local/src/robolectric/robolectric-robolectric-3.3.2

WORKDIR /robolectric_src
VOLUME /robolectric_src

CMD ["bash"]
