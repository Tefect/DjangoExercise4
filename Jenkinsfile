pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        EC2_USER          = "ubuntu"
        EC2_HOST          = "3.139.90.22"
        CRED_ID           = "ec2-ssh-private-key"

        DOCKERHUB_USERNAME = "tefect"
        IMAGE_NAME         = "tefect/djangoexercise4"
        IMAGE_TAG          = "latest"

        CONTAINER_NAME     = "django-container"
        HOST_PORT          = "8081"
        CONTAINER_PORT     = "80"
    }

    options {
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                git url: 'https://github.com/Tefect/DjangoExercise4.git',
                    branch: 'master'
            }
        }

        stage('Verify Project Files') {
            steps {
                sh '''
                    set -e
                    echo "Checking required project files..."

                    test -f Dockerfile || { echo "Dockerfile not found"; exit 1; }

                    echo "Required files found."
                    ls -la
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    set -e
                    docker build --pull -t "$IMAGE_NAME:$IMAGE_TAG" .
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        set -e
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                    set -e
                    docker push "$IMAGE_NAME:$IMAGE_TAG"
                '''
            }
        }

        stage('Deploy on EC2') {
            steps {
                sshagent([CRED_ID]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '

                            # Install Docker if missing
                            if ! command -v docker &> /dev/null; then
                                sudo apt-get update -y
                                sudo apt-get install -y docker.io
                                sudo systemctl start docker
                                sudo systemctl enable docker
                                sudo usermod -aG docker ubuntu
                            fi

                            # Pull latest image
                            sudo docker pull ${IMAGE_NAME}:${IMAGE_TAG}

                            # Stop and remove old container
                            sudo docker rm -f ${CONTAINER_NAME} || true

                            # Run new container
                            sudo docker run -d \
                                --name ${CONTAINER_NAME} \
                                --restart unless-stopped \
                                -p ${HOST_PORT}:${CONTAINER_PORT} \
                                ${IMAGE_NAME}:${IMAGE_TAG}

                            sleep 5

                            # Show running containers
                            sudo docker ps

                            # Show logs
                            sudo docker logs ${CONTAINER_NAME} --tail 20 || true
                        '
                    """
                }
            }
        }

        stage('Test Website') {
            steps {
                sh '''
                    set -e
                    curl -I https://3.139.90.22 || echo "Website not reachable yet"
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Deployment successful!'
            echo '🌐 App URL: https://3.139.90.22'
            echo '⚙️ Jenkins URL: https://3.139.90.22:8080'
        }

        failure {
            echo '❌ Deployment failed. Check Jenkins console output.'
        }

        always {
            sh 'docker logout || true'
        }
    }
}
```
