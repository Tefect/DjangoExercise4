pipeline {
    agent any

    environment {
        EC2_USER     = "ubuntu"
        EC2_HOST     = "3.144.147.163"
        CRED_ID      = "ec2-ssh-private-key"
        DOCKER_IMAGE = "tefect/djangoexercise4"
        DOCKER_CREDS = credentials('docker-hub-credentials')  // Jenkins credential: Username with password
    }

    triggers {
        githubPush()
    }

    stages {

        stage('Clone Repository') {
            steps {
                git branch: 'master',
                    url: 'https://github.com/Tefect/DjangoExercise4.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:latest ."
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh """
                    echo "${DOCKER_CREDS_PSW}" | docker login -u "${DOCKER_CREDS_USR}" --password-stdin
                    docker push ${DOCKER_IMAGE}:latest
                    docker logout
                """
            }
        }

        stage('Deploy on EC2') {
            steps {
                sshagent([CRED_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                            # Install Docker if not already installed
                            if ! command -v docker &> /dev/null; then
                                sudo apt-get update -y
                                sudo apt-get install -y docker.io
                                sudo systemctl start docker
                                sudo systemctl enable docker
                                sudo usermod -aG docker ubuntu
                            fi

                            # Kill any old dev server on port 8000
                            sudo fuser -k 8000/tcp || true

                            # Pull latest image
                            sudo docker pull ${DOCKER_IMAGE}:latest

                            # Stop and remove old container
                            sudo docker stop django-container || true
                            sudo docker rm   django-container || true

                            # Run new container on port 80
                            sudo docker run -d \
                                --name django-container \
                                --restart unless-stopped \
                                -p 80:80 \
                                ${DOCKER_IMAGE}:latest

                            sleep 5
                            sudo docker ps
                            sudo docker logs django-container --tail 20 || true
                        '
                    """
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS: App is live at http://${EC2_HOST}"
        }
        failure {
            echo "FAILURE: Check the console output above for errors."
        }
    }
}
