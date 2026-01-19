FROM ghcr.io/astral-sh/uv:python3.13-trixie AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    build-essential \
    bison \
    flex \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev

FROM python:3.13-slim-trixie

COPY --from=builder /app/.venv /app/.venv
ENV PATH="/app/.venv/bin:$PATH"
ENV FAVA_HOST="0.0.0.0"
EXPOSE 5000
CMD ["fava"]