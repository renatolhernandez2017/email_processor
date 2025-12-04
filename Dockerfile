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
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

# Instala Node.js 20 e Yarn
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && npm install --global yarn

# Criar diretório da aplicação
WORKDIR /workspaces/email_processor

# Copia dependências Ruby
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Instala dependências JS
COPY package.json yarn.lock ./
RUN yarn install

# Copia toda aplicação
COPY . .

# Build de assets (Tailwind etc.)
RUN npm run build || true

# Copia entrypoint
COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

# Expõe porta
EXPOSE 3000

ENTRYPOINT ["entrypoint.sh"]

# Comando padrão do contêiner
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
