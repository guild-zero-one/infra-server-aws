#!/bin/bash
set -euo pipefail

###############################################################################
# enable-https.sh
#
# Script completo para habilitar HTTPS no Nginx usando Let's Encrypt (Certbot)
# para o arquivo /etc/nginx/sites-available/simlady
#
# USO:
#   sudo ./enable-https.sh simlady.ddns.net seu.email@exemplo.com
#
# Se não passar parâmetros, usa defaults:
#   DOMAIN: simlady.ddns.net
#   EMAIL: joaogameszap@gmail.com
###############################################################################

DOMAIN="${1:-simlady.ddns.net}"
EMAIL="${2:-joaogameszap@gmail.com}"
NGINX_CONF="/etc/nginx/sites-available/simlady"
NGINX_ENABLED="/etc/nginx/sites-enabled/simlady"
WEBROOT="/var/www/certbot"
CERT_PATH="/etc/letsencrypt/live/${DOMAIN}/fullchain.pem"

echo "🚀 Iniciando habilitação de HTTPS para domínio: ${DOMAIN}"
echo "📧 E-mail: ${EMAIL}"
echo "📁 Arquivo Nginx: ${NGINX_CONF}"

# Verificar se está rodando como root
if [[ "$EUID" -ne 0 ]]; then
  echo "❌ Por favor, execute este script como root (sudo ./enable-https.sh)"
  exit 1
fi

# Verificar se o arquivo do Nginx existe
if [[ ! -f "${NGINX_CONF}" ]]; then
  echo "❌ Arquivo ${NGINX_CONF} não encontrado!"
  echo "   Crie o arquivo primeiro ou ajuste a variável NGINX_CONF no script."
  exit 1
fi

echo "✅ Arquivo Nginx encontrado: ${NGINX_CONF}"

# Fazer backup do arquivo atual
BACKUP_FILE="${NGINX_CONF}.backup.$(date +%Y%m%d_%H%M%S)"
echo "💾 Fazendo backup do arquivo Nginx para: ${BACKUP_FILE}"
cp "${NGINX_CONF}" "${BACKUP_FILE}"

# Instalar Certbot se não estiver instalado
if ! command -v certbot &> /dev/null; then
  echo "📦 Instalando Certbot..."
  apt update -y
  apt install -y certbot python3-certbot-nginx
else
  echo "✅ Certbot já está instalado"
fi

# Criar diretórios necessários
echo "📁 Criando diretórios necessários..."
mkdir -p /etc/letsencrypt
mkdir -p "${WEBROOT}"
mkdir -p /var/www/simlady/html

# Ajustar permissões
if id ubuntu &>/dev/null; then
  echo "👤 Ajustando permissões para usuário ubuntu..."
  chown -R ubuntu:ubuntu /etc/letsencrypt "${WEBROOT}" /var/www/simlady 2>/dev/null || true
fi

# Verificar se já existe certificado válido
SKIP_CERTBOT="false"
if [[ -f "${CERT_PATH}" ]]; then
  SUBJECT="$(openssl x509 -in "${CERT_PATH}" -noout -subject 2>/dev/null || echo "")"
  if echo "${SUBJECT}" | grep -q "CN=${DOMAIN}"; then
    echo "✅ Certificado válido já existe para ${DOMAIN}"
    SKIP_CERTBOT="true"
  else
    echo "🧹 Certificado antigo detectado. Será substituído..."
  fi
fi

# Criar página HTML básica se não existir
if [[ ! -f /var/www/simlady/html/index.html ]]; then
  echo "📄 Criando página HTML básica..."
  cat > /var/www/simlady/html/index.html <<EOF
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <title>${DOMAIN}</title>
</head>
<body>
  <h1>Bem-vindo ao ${DOMAIN}</h1>
  <p>Configuração HTTPS em andamento...</p>
</body>
</html>
EOF
fi

# Preparar configuração HTTP para Certbot
echo "🔧 Preparando configuração Nginx para Certbot..."

# Verificar se já tem configuração HTTP na porta 80
if ! grep -q "listen 80" "${NGINX_CONF}"; then
  echo "❌ Arquivo Nginx não tem configuração para porta 80."
  exit 1
fi

# Atualizar server_name no bloco HTTP existente (de _ para o domínio)
if grep -q "server_name _" "${NGINX_CONF}"; then
  echo "📝 Atualizando server_name de '_' para '${DOMAIN}'..."
  sed -i "s/server_name _;/server_name ${DOMAIN};/" "${NGINX_CONF}"
fi

# Adicionar location para acme-challenge no bloco HTTP (se não existir)
if ! grep -q "location /.well-known/acme-challenge/" "${NGINX_CONF}"; then
  echo "➕ Adicionando location para acme-challenge no bloco HTTP..."
  # Inserir após a linha do server_name, antes das outras locations
  sed -i "/server_name ${DOMAIN};/a\\
\\
    location /.well-known/acme-challenge/ {\\
        root ${WEBROOT};\\
    }" "${NGINX_CONF}"
fi

# Após gerar o certificado, vamos modificar o bloco HTTP para redirecionar para HTTPS
# (mas isso será feito depois do Certbot, então por enquanto deixamos como está)

# Garantir que o arquivo está habilitado
if [[ ! -L "${NGINX_ENABLED}" ]]; then
  echo "🔗 Habilitando site no Nginx..."
  ln -sf "${NGINX_CONF}" "${NGINX_ENABLED}"
fi

# Testar configuração do Nginx
echo "🧪 Testando configuração do Nginx..."
if ! nginx -t; then
  echo "❌ Erro na configuração do Nginx. Restaurando backup..."
  cp "${BACKUP_FILE}" "${NGINX_CONF}"
  exit 1
fi

# Recarregar Nginx
echo "🔄 Recarregando Nginx..."
systemctl reload nginx || systemctl restart nginx

# Gerar certificado com Certbot
if [[ "${SKIP_CERTBOT}" = "false" ]]; then
  echo "🔐 Gerando certificado SSL com Let's Encrypt..."
  
  certbot certonly \
    --nginx \
    --non-interactive \
    --agree-tos \
    --email "${EMAIL}" \
    -d "${DOMAIN}" \
    --redirect \
    --no-eff-email || {
    echo "❌ Erro ao gerar certificado. Verifique:"
    echo "   1. O domínio ${DOMAIN} aponta para este servidor"
    echo "   2. As portas 80 e 443 estão abertas no firewall"
    echo "   3. O Nginx está rodando corretamente"
    exit 1
  }
  
  echo "✅ Certificado gerado com sucesso!"
else
  echo "⏭️  Pulando geração de certificado (já existe)"
fi

# Verificar se o certificado foi criado
if [[ ! -f "${CERT_PATH}" ]]; then
  echo "❌ Certificado não encontrado em ${CERT_PATH}"
  exit 1
fi

# Atualizar configuração do Nginx para usar HTTPS
echo "📝 Adicionando bloco HTTPS ao arquivo Nginx..."

# Verificar se já tem bloco HTTPS
if ! grep -q "listen 443 ssl" "${NGINX_CONF}"; then
  echo "➕ Criando bloco HTTPS preservando upstreams e locations existentes..."
  
  # Extrair apenas o conteúdo do bloco server HTTP (locations) para reusar no HTTPS
  # Vamos adicionar o bloco HTTPS completo no final do arquivo
  cat >> "${NGINX_CONF}" <<'HTTPS_BLOCK_EOF'

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name DOMAIN_PLACEHOLDER;

    ssl_certificate     /etc/letsencrypt/live/DOMAIN_PLACEHOLDER/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/DOMAIN_PLACEHOLDER/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    location /.well-known/acme-challenge/ {
        root WEBROOT_PLACEHOLDER;
    }

    # Frontend Web
    location / {
        proxy_pass http://frontend_web;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    # Backend API
    location /api {
        proxy_pass http://backend_api/;
        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_pass_header Set-Cookie;
        proxy_pass_header Cookie;
        add_header Set-Cookie $upstream_http_set_cookie;
        add_header Cache-Control "no-store" always;

        rewrite ^/api/(.*)$ /$1 break;
    }

    # Gemini API
    location /api/gemini {
        proxy_pass http://gemini_api;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        rewrite ^/api/gemini/(.*)$ /$1 break;
    }
}
HTTPS_BLOCK_EOF
  
  # Substituir placeholders
  sed -i "s/DOMAIN_PLACEHOLDER/${DOMAIN}/g" "${NGINX_CONF}"
  sed -i "s|WEBROOT_PLACEHOLDER|${WEBROOT}|g" "${NGINX_CONF}"
  
  echo "✅ Bloco HTTPS adicionado preservando toda a estrutura de proxy!"
else
  echo "⏭️  Bloco HTTPS já existe no arquivo"
fi

# Testar configuração novamente
echo "🧪 Testando configuração final do Nginx..."
if ! nginx -t; then
  echo "❌ Erro na configuração do Nginx após adicionar HTTPS."
  echo "   Restaurando backup: ${BACKUP_FILE}"
  cp "${BACKUP_FILE}" "${NGINX_CONF}"
  nginx -t
  systemctl reload nginx
  exit 1
fi

# Recarregar Nginx com configuração final
echo "🔄 Recarregando Nginx com configuração HTTPS..."
systemctl reload nginx

# Verificar renovação automática
if ! systemctl is-enabled certbot.timer &>/dev/null; then
  echo "⏰ Configurando renovação automática de certificados..."
  systemctl enable certbot.timer
  systemctl start certbot.timer
fi

echo ""
echo "✅ HTTPS configurado com sucesso!"
echo ""
echo "📋 Resumo:"
echo "   Domínio: ${DOMAIN}"
echo "   Certificado: ${CERT_PATH}"
echo "   Configuração Nginx: ${NGINX_CONF}"
echo "   Backup: ${BACKUP_FILE}"
echo ""
echo "🌐 Teste acessando: https://${DOMAIN}"
echo ""
echo "🔄 O certificado será renovado automaticamente pelo Certbot."

