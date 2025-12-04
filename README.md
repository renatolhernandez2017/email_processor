# E-mails MVP Rails

## Visão geral
Aplicação Ruby on Rails para processar arquivos .eml (e-mails), extrair informações estruturadas e salvar os resultados no banco de dados, contando com arquitetura limpa, background jobs, logs persistentes e interface web intuitiva.

---

## 🧱 Arquitetura

- **Rails 7.1.3** – Framework principal.
- **Ruby 3.3.1** – Linguagem principal.
- **Docker e Docker-compose.yml** – Para executar o ambiente de Desenvolvimento.
- **PostgreSQL** – Banco de dados relacional.
- **Sidekiq** – Para execução de tarefas em segundo plano.
- **Redis** – Para mensagens do progresso em tempo real.
- **TailwindCss** – Para estilização da aplicação web.

---

## Como rodar localmente

No terminal:
Clonar o projeto via https ou ssh

- HTTPS -> git clone https://github.com/renatolhernandez2017/email_processor.git
- SSH -> git clone git@github.com:renatolhernandez2017/email_processor.git

Acessar pasta:
- cd email_processor

Subir o projeto:
- docker-compose down
- docker-compose build --no-cache
- docker-compose up

Os comandos acima vai:
 - Subir a aplicação
 - Criar o banco de dados
 - Gerar as migrations

---

## Endpoint principal
- http://localhost:3000

---

## Como enviar emails para processamento
- Na tela principal, basta anexar os arquivos .eml (é possível anexar vários ao mesmo tempo) e clicar em **Enviar e Processar**

---

## Para visualizar os resultados (customers + logs).
- Na tela principal, há um menu no topo que permite visualizar os resultados de **customers** e **logs**

---

## Para rodar os testes
Abra um outro terminal e execute os seguintes comandos:
- docker-compose run --rm email_processor bash
- bundle exec rspec
