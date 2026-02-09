FROM mcr.microsoft.com/devcontainers/base:ubuntu

LABEL org.opencontainers.image.source=https://github.com/raidel-a/dotfiles
LABEL org.opencontainers.image.description="Prebuilt base image for devcontainers with WezTerm multiplexing support."

# Optional args
ARG DOTFILES_REPO=https://github.com/raidel-a/dotfiles
ARG GIT_SSH_REWRITE=off
ENV GIT_SSH_REWRITE=${GIT_SSH_REWRITE}

# Install prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends \
  curl \
  gnupg \
  ca-certificates \
  wget \
  unzip \
  fontconfig

# Install WezTerm nightly
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -fsSL https://apt.fury.io/wez/gpg.key | gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg && \
  echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | tee /etc/apt/sources.list.d/wezterm.list && \
  chmod 644 /usr/share/keyrings/wezterm-fury.gpg 

RUN apt-get update && apt-get install -y --no-install-recommends wezterm-nightly && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  touch /.dockerenv

# Switch to non-root user
RUN usermod --shell "$(which zsh)" vscode
USER vscode
WORKDIR /home/vscode
ENV HOME=/home/vscode

# Install Homebrew for Linux
RUN NONINTERACTIVE=1 bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

# Clone dotfiles repo to .config (matching your macOS structure)
RUN git clone --depth=1 $DOTFILES_REPO ~/.config && \
  chmod +x ~/.config/install.sh && \
  ~/.config/install.sh

CMD ["/usr/bin/zsh"]
