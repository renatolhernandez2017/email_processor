#!/bin/bash
set -e

echo "===> Instalando gems se precisar..."
bundle install --jobs=4

echo "===> Preparando banco..."
bundle exec rails db:create db:migrate

echo "===> Limpando PID..."
rm -f tmp/pids/server.pid

echo "===> Iniciando aplicação..."
exec "$@"
