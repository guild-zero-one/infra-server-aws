pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/guild-zero-one/infra-server-aws.git'
        DEPLOY_DIR = '/var/www/deploy'
        BRANCH = 'main'
    }

    stages {
        stage('Update EC2') {
            steps {
                sh '''
                sudo apt update -y
                sudo apt upgrade -y
                sudo apt install ca-certificates -y
                sudo update-ca-certificates -y
                sudo apt install maven -y
                sudo apt install nodejs -y
                sudo apt install npm -y
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
