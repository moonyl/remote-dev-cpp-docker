FROM ubuntu:18.04

RUN DEBIAN_FRONTEND="noninteractive" apt-get update && apt-get -y install tzdata \
  software-properties-common \
  lsb-release

COPY kitware-archive-latest.asc ./
RUN cat ./kitware-archive-latest.asc | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null

RUN apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main"

RUN apt-get update \
  && apt-get install -y ssh \
  build-essential \
  gcc \
  g++ \
  g++-8 \
  gdb \
  clang \
  cmake \
  rsync \
  tar \
  python \
  && apt-get clean

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 70 --slave /usr/bin/g++ g++ /usr/bin/g++-7 --slave /usr/bin/gcov gcov /usr/bin/gcov-7
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80 --slave /usr/bin/g++ g++ /usr/bin/g++-8 --slave /usr/bin/gcov gcov /usr/bin/gcov-8
RUN update-alternatives --set gcc /usr/bin/gcc-8

RUN ( \
  echo 'PermitRootLogin yes'; \
  echo 'PasswordAuthentication yes'; \
  echo 'Subsystem sftp /usr/lib/openssh/sftp-server'; \
  ) > /etc/ssh/sshd_config_test_clion \
  && mkdir /run/sshd

RUN useradd -m user \
  && yes password | passwd user

RUN usermod -s /bin/bash user

CMD ["/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config_test_clion"]
