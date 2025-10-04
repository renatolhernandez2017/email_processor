FROM ruby:3.3.1

# Evita perguntas interativas e atualiza pacotes
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    iputils-ping \
    netcat-openbsd \
    build-essential \
    libpq-dev \
    curl \
    git \
    vim \
    nodejs \
    npm \
    gettext-base \
    firebird-dev firebird-utils \
    openvpn \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Instala Node.js e Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && npm install --global yarn

# Cria diretório da aplicação
WORKDIR /workspaces/unipharmus_v2

# Copia Gemfile e Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Instala gems
RUN bundle install

COPY package.json yarn.lock ./
RUN yarn install

# Copia tudo
COPY . .

# Build da aplicação (Tailwind/Vue)
RUN npm run build

# Expõe porta do Rails
EXPOSE 3003

# Comando default
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3003"]
