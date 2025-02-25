# Instruções de Utilização

## Convite de Acesso ao Mailtrap

1. Acesse a página de convite de acesso:  
   - [http://localhost:3000/admin/users](http://localhost:3000/admin/users)
2. Preencha o formulário e envie o convite.
3. Acesse o Mailtrap:  
   - [https://mailtrap.io/](https://mailtrap.io/)
4. Pegue a senha no Chat de Senhas e verifique o e-mail recebido na caixa de entrada.

## Templates para usar na criação do envio do email
   - [https://postmarkapp.com/transactional-email-templates](https://postmarkapp.com/transactional-email-templates)

### Formatação do Código

- Utilize o Standard RB para formatação do código:  
  - [Standard RB](https://github.com/standardrb/standard)
- Utilize a extensão do VS Code para Standard RB:  
  - [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=testdouble.vscode-standard-ruby)
- Verifique se na configuração do VS Code está habilitado:
  ```json
  "editor.formatOnSave": true,
  "[ruby]": {
      "editor.defaultFormatter": "testdouble.vscode-standard-ruby"
  }
  ```

## Git Workflow

1. Criar uma Nova Branch - baseado no ID-Inteligencia trabalhar na sua branch normalmente fazendo todas as alterações necessárias
2. Adicionar Arquivos Novos
3. Antes de Fazer o Commit - Tecnica para fazer um merge com a main e verificar se a sua versao esta com a ultima versao publicada
4. Fazer um Commit com Comentários - Usar o Visual Studio de preferencia 
5. Fazer um Push para a Branch 


### Criar Branch a partir do Projeto e Pegar o Código Localmente

```bash
git fetch origin
git checkout SUA_BRANCH
```

### Adicionar Arquivos Novos

```bash
git add .
```

### Antes de Fazer o Commit

Quando estiver trabalhando em uma branch, previna outras modificações antes de subir:

```bash
git stash
git checkout main
git pull
git checkout -b SUA_BRANCH
git merge main
git stash list
git stash pop
git add .
```

### Fazer um Commit com Comentários

```bash
git commit -m "TEXTO DO COMMIT"
```

### Fazer um Push para a Branch

```bash
git push
```

### Verificar a Branch que Está Trabalhando

```bash
git branch
```

### Fazer um Checkout para Main

```bash
git checkout main
```

### Fazer um Pull

```bash
git pull
```

### Verificar o Status do Git

```bash
git status
```

**Não esqueça de instalar o SSH, no GitHub clone com SSH e não com HTTPS.**

# Lista de comandos rails

## para rodar depois de um pull
```ruby
bundle
yarn install
rails db:drop 
rails db:create 
rails db:migrate 
rails db:seed
bin/dev
```

### remover esses comandos  por que vamos usar o STIMULOS
```ruby
rails assets:clobber
```

### para gerar uma policy
```ruby
rails g pundit:policy post
```

### gerar stimulus
```ruby
rails g stimulus upload
upload é o nome do arquivo que vai gerar
passar o form_with data: {controller: "upload" }
```
# Banco de dados
## sqltoad
```html
https://sql.toad.cz/
```
### load -consult


# WEBHOOK
## instalando localtunnel
npm install -g localtunnel

## subir na porta
lt --port 3000

> toda vez gerar uma nova url
> ele entrega uma url dai clica nela
> clicar na pagina para pegar a senha e fazer um submit e da 

### a senha é o seu consultip usar na pagina para pegar isso
https://theboroer.github.io/localtunnel-www/


> concatenar e gerar o link com a autorizacao para o webhook


### ir para
http://localhost:3000/sidekiq# consult
