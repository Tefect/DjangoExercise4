pipeline {
    agent any

    environment {
        // ── Your existing EC2 details (unchanged) ────────────────────────
        EC2_USER = "ubuntu"
        EC2_HOST = "3.144.147.163"
        CRED_ID  = "ec2-ssh-private-key"

        // ── Docker Hub image (create this repo on hub.docker.com) ────────
        DOCKER_IMAGE = "tefect/djangoexercise4"
        DOCKER_CREDS = "docker-hub-credentials"
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
                script {
                    docker.build("${DOCKER_IMAGE}:latest")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDS) {
                        docker.image("${DOCKER_IMAGE}:latest").push()
                        echo "Image pushed to Docker Hub"
                    }
                }
            }
        }

        stage('Deploy on EC2') {
            steps {
                script {
                    sshagent([CRED_ID]) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                                # Install Docker if not already present
                                if ! command -v docker &> /dev/null; then
                                    sudo apt-get update -y
                                    sudo apt-get install -y docker.io
                                    sudo systemctl start docker
                                    sudo systemctl enable docker
                                    sudo usermod -aG docker ubuntu
                                fi

                                # Kill any old dev server still on port 8000
                                sudo fuser -k 8000/tcp || true

                                # Pull latest image from Docker Hub
                                sudo docker pull ${DOCKER_IMAGE}:latest

                                # Stop and remove old container if it exists
                                sudo docker stop django-container || true
                                sudo docker rm   django-container || true

                                # Run new container — port 80 on EC2 → port 80 in container
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
