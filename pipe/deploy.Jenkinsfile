pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/guild-zero-one/infra-server-aws.git'
        FRONT_URL = 'https://github.com/guild-zero-one/stock-client.git'
        DEPLOY_DIR = '/var/www/deploy'
        FRONT_DIR = '${DEPLOY_DIR}/simlady-stock'
        BRANCH = 'main'
    }

    stages {
        stage('Update EC2') {
            steps {
                sh '''
                sudo dpkg --configure -a

                sudo apt autoremove -y

                sudo apt upgrade -y
                sudo apt update -y
                sudo apt install ca-certificates -y
                sudo update-ca-certificates -y
                sudo apt install maven -y
                sudo apt install nodejs -y
                sudo apt install npm -y
                sudo npm install -g pm2
                '''
            }
        }

        stage('Install Docker and Docker Compose') {
            steps {
                sh '''
                sudo apt install docker.io -y
                sudo apt install docker-compose -y
                '''
            }
        }

        stage('Clone/Update Repository') {
            steps {
                sh """
                sudo mkdir -p ${DEPLOY_DIR}
                sudo chown -R \$USER:\$USER ${DEPLOY_DIR}
                cd ${DEPLOY_DIR}

                if [ ! -d ".git" ]; then
                    git clone ${REPO_URL} .
                fi

                git fetch --all
                git checkout ${BRANCH}
                git pull origin ${BRANCH}
                """
            }
        }


        stage('Clone/Update Frontend Repository') {
            steps {
                sh """
                sudo mkdir -p ${DEPLOY_DIR}
                sudo chown -R \$USER:\$USER ${DEPLOY_DIR}
                cd ${DEPLOY_DIR}

                if [ ! -d "simlady-stock" ]; then
                    git clone ${FRONT_URL} simlady-stock
                fi

                cd simlady-stock
                git fetch --all
                git checkout ${BRANCH}
                git pull origin ${BRANCH}
                """
            }
        }

        stage('Build and Run Next.js') {
            steps {
                withCredentials([
                    string(credentialsId: 'SERPAPI_API_KEY', variable: 'SERPAPI_API_KEY'),
                    string(credentialsId: 'JWT_SECRET', variable: 'JWT_SECRET')
                ]) {
                    sh """
                    cd ${FRONT_DIR}
                    
                    # Criar arquivo .env.local para o Next.js
                    echo "NEXT_PUBLIC_API_URL=http://localhost:8000" > .env.local
                    echo "NEXT_PUBLIC_GEMINI_API_URL=http://localhost:30000" >> .env.local
                    echo "SERPAPI_API_KEY=\$SERPAPI_API_KEY" >> .env.local
                    echo "JWT_SECRET=\$JWT_SECRET" >> .env.local
                    
                    # Instalar dependências
                    npm install
                    
                    # Buildar a aplicação Next.js
                    npm run build
                    
                    # Parar o processo anterior se existir
                    pm2 stop simlady-stock || true
                    pm2 delete simlady-stock || true
                    
                    # Iniciar o Next.js com PM2
                    pm2 start npm --name "simlady-stock" -- start
                    
                    # Salvar a configuração do PM2
                    pm2 save
                    
                    # Configurar PM2 para iniciar no boot
                    pm2 startup || true
                    """
                }
            }
        }

        stage('Create .env file') {
            steps {
                withCredentials([
                    string(credentialsId: 'SERPAPI_API_KEY', variable: 'SERPAPI_API_KEY'),
                    string(credentialsId: 'JWT_SECRET', variable: 'JWT_SECRET'),
                    string(credentialsId: 'GEMINI_API_KEY', variable: 'GEMINI_API_KEY'),
                    string(credentialsId: 'BOT_TOKEN', variable: 'BOT_TOKEN'),
                    string(credentialsId: 'DB_HOST', variable: 'DB_HOST'),
                    string(credentialsId: 'DB_PORT', variable: 'DB_PORT'),
                    string(credentialsId: 'DB_USER', variable: 'DB_USER'),
                    string(credentialsId: 'DB_PASSWORD', variable: 'DB_PASSWORD'),
                    string(credentialsId: 'DB_NAME', variable: 'DB_NAME'),
                    string(credentialsId: 'SPRING_PROFILES_ACTIVE', variable: 'SPRING_PROFILES_ACTIVE'),
                    string(credentialsId: 'SPRING_RABBITMQ_HOST', variable: 'SPRING_RABBITMQ_HOST'),
                    string(credentialsId: 'SPRING_RABBITMQ_PORT', variable: 'SPRING_RABBITMQ_PORT'),
                    string(credentialsId: 'SPRING_RABBITMQ_USERNAME', variable: 'SPRING_RABBITMQ_USERNAME'),
                    string(credentialsId: 'SPRING_RABBITMQ_PASSWORD', variable: 'SPRING_RABBITMQ_PASSWORD'),
                    string(credentialsId: 'SYSADMIN_USER', variable: 'SYSADMIN_USER'),
                    string(credentialsId: 'SYSADMIN_EMAIL', variable: 'SYSADMIN_EMAIL'),
                    string(credentialsId: 'SYSADMIN_PASSWORD', variable: 'SYSADMIN_PASSWORD'),
                ]) {
                    sh """
                    cd ${DEPLOY_DIR}
                    cat > .env << EOF
SERPAPI_API_KEY=${SERPAPI_API_KEY}
JWT_SECRET=${JWT_SECRET}
GEMINI_API_KEY=${GEMINI_API_KEY}
BOT_TOKEN=${BOT_TOKEN}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
DB_NAME=${DB_NAME}
SPRING_PROFILES_ACTIVE=${SPRING_PROFILES_ACTIVE}
SPRING_RABBITMQ_HOST=${SPRING_RABBITMQ_HOST}
SPRING_RABBITMQ_PORT=${SPRING_RABBITMQ_PORT}
SPRING_RABBITMQ_USERNAME=${SPRING_RABBITMQ_USERNAME}
SPRING_RABBITMQ_PASSWORD=${SPRING_RABBITMQ_PASSWORD}
SYSADMIN_USER=${SYSADMIN_USER}
SYSADMIN_EMAIL=${SYSADMIN_EMAIL}
SYSADMIN_PASSWORD=${SYSADMIN_PASSWORD}
EOF
                    chmod 600 .env
                    """
                }
            }
        }

        stage('Deploy na EC2') {
            steps {
                sh """
                cd ${DEPLOY_DIR}
                sudo docker-compose down || true
                sudo docker-compose rm -f || true
                sudo docker-compose up -d --build --force-recreate
                sudo docker-compose ps
                """
            }
        }
    }
}
