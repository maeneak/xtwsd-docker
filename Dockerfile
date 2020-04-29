FROM debian:latest

ENV TZ="US/Pacific"
ENV HFILE_PATH=/xtwsd/harmonics-2004-06-14.tcd
ENV BOOST_LIBRARYDIR=/xtwsd/boost/libs
ENV BOOST_ROOT=/xtwsd/boost
ENV PATH="/xtwsd/xtwsd/build:/xtwsd/boost:/xtwsd/boost/libs:${PATH}"
ADD https://flaterco.com/files/xtide/libtcd-2.2.7-r2.tar.bz2 /xtwsd/
ADD https://dl.bintray.com/boostorg/release/1.73.0/source/boost_1_73_0.tar.bz2 /xtwsd/
ADD https://github.com/manimaul/MX-Tides-iOS/blob/master/resources/harmonics-2004-06-14.tcd?raw=true /xtwsd/

RUN chmod 644 /xtwsd/harmonics-2004-06-14.tcd
RUN apt-get -y -q update
RUN apt-get -y -q install clang \
            git \
            cmake \
            zlib1g-dev \
            libpng-dev \
            ragel \
            libssl-dev

RUN cd /xtwsd; git clone --recursive https://github.com/joelkoz/xtwsd.git
RUN cd /xtwsd; tar jxf boost_1_73_0.tar.bz2; mv boost_1_73_0 boost
RUN cd /xtwsd/boost; ./bootstrap.sh -with-libraries=system -with-toolset=clang; ./b2
RUN cd /xtwsd; tar jxf libtcd-2.2.7-r2.tar.bz2 
RUN cd /xtwsd/libtcd-2.2.7; ./configure; make; su; make install
RUN cd /xtwsd/xtwsd; mkdir build; cd /xtwsd/xtwsd/build; cmake -Wno-dev ..; make
ENTRYPOINT [ "xtwsd", "8080" ]
