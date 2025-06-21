FROM python:3.10-slim

# Install system deps & Cog
RUN apt-get update && \
    apt-get install -y --no-install-recommends git curl build-essential && \
    rm -rf /var/lib/apt/lists/* && \
    curl -Lo /usr/local/bin/cog \
      https://github.com/replicate/cog/releases/latest/download/cog_$(uname -s)_$(uname -m) && \
    chmod +x /usr/local/bin/cog

# Clone & build the Cog model
RUN git clone https://github.com/replicate/flux-fine-tuner.git /app
WORKDIR /app
RUN cog build

# Copy in your entrypoint
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
