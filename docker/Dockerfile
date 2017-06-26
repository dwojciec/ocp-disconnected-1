FROM registry.access.redhat.com/rhel7/rhel
MAINTAINER Didier Wojciechowski <dwojciec@redhat.com>

LABEL io.k8s.display-name="Image for OCP disconnected" \
      io.k8s.description="Docker image to build all contents for OCP disconnected"
ADD bin/*  /usr/local/bin/
RUN yum install -y \
        --enablerepo=rhel-7-server-rpms \
        --enablerepo=rhel-7-server-extras-rpms \
        --enablerepo=rhel-7-server-ose-3.5-rpms \
        --enablerepo=rhel-7-fast-datapath-rpms \
        git \
        docker \
        docker-common \
        atomic-openshift-utils
RUN mkdir -p /data && mkdir /exports
WORKDIR /data
RUN git clone https://github.com/dwojciec/ocp-disconnected-1.git
RUN mkdir -p /data/ocp-disconnected/build
VOLUME /data/ocp-disconnected/build
COPY conf.yml  /data/ocp-disconnected/conf.yml     
WORKDIR /data/ocp-disconnected
ENTRYPOINT ["/bin/bash","/usr/local/bin/entrypoint.sh"]]
