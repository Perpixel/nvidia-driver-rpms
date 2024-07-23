ARG BASE_IMAGE="${BASE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"
# Build NVIDIA drivers
#
# This will build the rpm from rpmfusion source and then make
# them available to the final image in this container.
#
FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} as nvidia-builder
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"
COPY scripts/install-build-env.sh /tmp/scripts/
RUN /tmp/scripts/install-build-env.sh
RUN rm -rf /tmp/* /var/*
# End
