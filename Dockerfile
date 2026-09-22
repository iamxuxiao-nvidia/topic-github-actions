FROM ubuntu:24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        build-essential \
        ca-certificates \
        curl \
        git \
        python3 \
        unzip \
        zip \
    && rm -rf /var/lib/apt/lists/*

# Install the same Bazel 7 version used by local Bazelisk builds.
COPY .bazelversion /tmp/.bazelversion
RUN set -eu; \
    bazel_version="$(cat /tmp/.bazelversion)"; \
    case "$(dpkg --print-architecture)" in \
        amd64) bazel_arch=x86_64 ;; \
        arm64) bazel_arch=arm64 ;; \
        *) echo "Unsupported architecture" >&2; exit 1 ;; \
    esac; \
    bazel_file="bazel-${bazel_version}-linux-${bazel_arch}"; \
    bazel_url="https://github.com/bazelbuild/bazel/releases/download/${bazel_version}"; \
    cd /tmp; \
    curl --fail --location --retry 3 --output "${bazel_file}" "${bazel_url}/${bazel_file}"; \
    curl --fail --location --retry 3 --output "${bazel_file}.sha256" "${bazel_url}/${bazel_file}.sha256"; \
    sha256sum --check "${bazel_file}.sha256"; \
    install -m 0755 "${bazel_file}" /usr/local/bin/bazel; \
    test "$(bazel --version)" = "bazel ${bazel_version}"; \
    rm "${bazel_file}" "${bazel_file}.sha256" /tmp/.bazelversion

WORKDIR /workspace

CMD ["bash"]
