FROM fedora:rawhide
ARG dockerfile_url
ENV DOCKERFILE_URL=$dockerfile_url

RUN rpm --import https://src.fedoraproject.org/rpms/fedora-repos/blob/main/f/RPM-GPG-KEY-fedora-35-primary && \
    echo "install make cmake gcc-c++ \
                   gmp-devel.x86_64 mpfr-devel.x86_64 \
                   boost-devel.x86_64 \
                   ntl-devel.x86_64 \
                   ipe-devel.x86_64 \
                   eigen3-devel.noarch \
                   qt5-qtbase-devel.x86_64 \
                   qt5-qtscript-devel.x86_64 \
                   qt5-qtsvg-devel.x86_64 \
                   qt5-qttools-devel.x86_64 \
                   libQGLViewer-qt5-devel.x86_64 \
                   mesa-libGLU-devel \
                   OpenMesh-devel \
                   tbb-devel \
                   zlib-devel.x86_64 \
		   diffutils \
                   tar" >> dnf-cmd && \
    echo update >> dnf-cmd && \
    echo run >> dnf-cmd && \
    dnf -y shell dnf-cmd && rm dnf-cmd && \
    dnf clean all

ENV CGAL_TEST_PLATFORM="Fedora-rawhide"
ENV CGAL_CMAKE_FLAGS="('-DCGAL_HEADER_ONLY:BOOL=TRUE')"
ENV INIT_FILE=/tmp/init.cmake
COPY init.cmake /tmp/init.cmake
