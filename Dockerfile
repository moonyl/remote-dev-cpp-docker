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
  gdb \
  clang \
  cmake \
  rsync \
  tar \
  python \
  && apt-get clean

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
