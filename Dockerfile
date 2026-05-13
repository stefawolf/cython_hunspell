# Stage 1: build the wheel
FROM python:3.12-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    automake \
    libtool \
    autopoint \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

RUN pip install --no-cache-dir "cython>=3.0" setuptools wheel && \
    python -m cython --cplus hunspell/hunspell.pyx && \
    pip wheel . --wheel-dir /dist --no-deps

# Stage 2: export the wheel
FROM scratch AS exporter
COPY --from=builder /dist/*.whl /

# Stage 3: install and test
FROM python:3.12-slim AS tester

RUN apt-get update && apt-get install -y --no-install-recommends \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /dist/*.whl /dist/
COPY requirements-test.txt tests/ ./tests/
COPY hunspell/dictionaries/ ./hunspell/dictionaries/

RUN pip install --no-cache-dir /dist/*.whl pytest

CMD ["pytest", "tests/", "-v"]
