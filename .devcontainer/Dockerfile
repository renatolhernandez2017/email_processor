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
    && rm -rf /var/lib/apt/lists/*

# Instala Node.js e Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && npm install --global yarn

# Cria diretório da aplicação
WORKDIR /app

# Copia Gemfile e Gemfile.lock
COPY ./Gemfile ./Gemfile
COPY ./Gemfile.lock ./Gemfile.lock

# Instala gems
RUN gem install bundler && bundle install

# Se houver package.json mas sem yarn.lock, crie automaticamente
RUN if [ -f package.json ] && [ ! -f yarn.lock ]; then yarn install; fi

# Copia código da aplicação
COPY . .

# Expõe porta do Rails
EXPOSE 3003

# Comando default
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3003"]
