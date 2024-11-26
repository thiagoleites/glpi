#!/bin/bash

# Variáveis
GLPI_PATH="/var/www/html/glpi"
BACKUP_PATH="/var/backups/glpi"
DATE=$(date +"%Y%m%d%H%M%S")
DATABASE_NAME="nome_do_banco"
DATABASE_USER="usuario_do_banco"
DATABASE_PASS="senha_do_banco"
LATEST_GLPI_URL="https://github.com/glpi-project/glpi/releases/download/10.0.17/glpi-10.0.17.tgz"

# Passo 1: Criar diretório de backup
mkdir -p $BACKUP_PATH

# Passo 2: Fazer backup do banco de dados
echo "Realizando backup do banco de dados..."
mysqldump -u$DATABASE_USER -p$DATABASE_PASS $DATABASE_NAME > $BACKUP_PATH/glpi_db_backup_$DATE.sql
if [ $? -ne 0 ]; then
    echo "Erro ao realizar o backup do banco de dados."
    exit 1
fi
echo "Backup do banco de dados realizado com sucesso."

# Passo 3: Fazer backup dos arquivos
echo "Realizando backup dos arquivos..."
tar -czvf $BACKUP_PATH/glpi_files_backup_$DATE.tar.gz $GLPI_PATH
if [ $? -ne 0 ]; then
    echo "Erro ao realizar o backup dos arquivos."
    exit 1
fi
echo "Backup dos arquivos realizado com sucesso."

# Passo 4: Baixar a versão mais recente do GLPI
echo "Baixando a versão mais recente do GLPI..."
wget -O /tmp/glpi.tgz $LATEST_GLPI_URL
if [ $? -ne 0 ]; then
    echo "Erro ao baixar a nova versão do GLPI."
    exit 1
fi

# Passo 5: Descompactar nova versão
echo "Descompactando a nova versão..."
tar -xvzf /tmp/glpi.tgz -C /tmp
if [ $? -ne 0 ]; then
    echo "Erro ao descompactar o GLPI."
    exit 1
fi

# Passo 6: Atualizar a instalação
echo "Atualizando a instalação do GLPI..."
rm -rf $GLPI_PATH/*
cp -r /tmp/glpi/* $GLPI_PATH/
if [ $? -ne 0 ]; then
    echo "Erro ao copiar os novos arquivos do GLPI."
    exit 1
fi

# Passo 7: Ajustar permissões
echo "Ajustando permissões..."
chown -R www-data:www-data $GLPI_PATH
find $GLPI_PATH -type d -exec chmod 755 {} \;
find $GLPI_PATH -type f -exec chmod 644 {} \;

# Passo 8: Limpar arquivos temporários
echo "Limpando arquivos temporários..."
rm -rf /tmp/glpi
rm /tmp/glpi.tgz

echo "Atualização do GLPI concluída com sucesso!"
