pipeline {
    agent any
    
    triggers {
        githubPush()
    }

    environment {
        // Updated credentials and image info
        DOCKERHUB_USERNAME = "tefect"
        IMAGE_NAME         = "tefect/djangoexercise4"
        IMAGE_TAG          = "latest"
        
        // Container management
        CONTAINER_NAME     = "django-jenkinstest"
        HOST_PORT          = "8081"
        CONTAINER_PORT     = "8000" // Standard Django port inside container
        
        // New Server IP
        EC2_PUBLIC_IP      = "3.14.84.24"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Tefect/DjangoExercise4.git', 
                    branch: 'master'
            }
        }

        stage('Verify Files') {
            steps {
                sh '''
                    echo "Scanning for Django project files..."
                    test -f manage.py || { echo "manage.py missing!"; exit 1; }
                    test -f Dockerfile || { echo "Dockerfile missing!"; exit 1; }
                '''
            }
        }

        stage('Build & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-hub-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        docker build -t $IMAGE_NAME:$IMAGE_TAG .
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $IMAGE_NAME:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Deploy Locally') {
            steps {
                sh '''
                    # Kill old container if it exists
                    docker rm -f "$CONTAINER_NAME" || true
                    
                    # Run the new one
                    docker run -d \
                      --name "$CONTAINER_NAME" \
                      --restart unless-stopped \
                      -p "$HOST_PORT:$CONTAINER_PORT" \
                      "$IMAGE_NAME:$IMAGE_TAG"
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh "sleep 5 && curl -I http://localhost:$HOST_PORT || echo 'Container starting...'"
            }
        }
    }

    post {
        success {
            echo "✅ DEPLOYMENT COMPLETE"
            echo "🌐 Access your app at: http://${EC2_PUBLIC_IP}:${HOST_PORT}"
        }
        failure {
            echo "❌ DEPLOYMENT FAILED"
        }
    }
}
