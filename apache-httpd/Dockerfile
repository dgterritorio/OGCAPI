FROM debian:bookworm-slim

# Prevent interactive prompts during apt installations
ENV DEBIAN_FRONTEND=noninteractive

# Install Apache and mod_evasive
RUN apt-get update && apt-get install -y \
    apache2 \
    libapache2-mod-evasive \
    && rm -rf /var/lib/apt/lists/*

# Create a log directory for mod_evasive and give Apache permissions
RUN mkdir -p /var/log/mod_evasive && \
    chown www-data:www-data /var/log/mod_evasive

# Copy your custom configuration (overwriting Debian's default)
COPY evasive.conf /etc/apache2/mods-available/evasive.conf

# Ensure the module is enabled
RUN a2enmod evasive

# Expose standard HTTP port
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]