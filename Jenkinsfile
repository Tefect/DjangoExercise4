pipeline {
    agent any

    environment {
        // --- MODIFY THESE IF NEEDED ---
        EC2_USER = "ubuntu"
        EC2_HOST = "44.197.180.64" 
        PROJECT_DIR = "/home/ubuntu/pythonprojects/DjangoExercise4" // Path on your EC2
        GIT_REPO = "https://github.com/Tefect/DjangoExercise4"
    }

    stages {
        stage('Deploy & Update on EC2') {
            steps {
                script {
                    // This uses the 'ec2-ssh-private-key' you already have saved in Jenkins
                    sshagent (credentials: ['ec2-ssh-private-key']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                            # 1. Ensure the directory exists or clone it if first time
                            if [ ! -d "${PROJECT_DIR}" ]; then
                                mkdir -p /home/ubuntu/pythonprojects
                                cd /home/ubuntu/pythonprojects
                                git clone ${GIT_REPO}
                            fi

                            # 2. Enter project and pull latest changes
                            cd ${PROJECT_DIR}
                            git pull origin main

                            # 3. Setup Virtual Environment and Install dependencies
                            python3 -m venv venv
                            source venv/bin/activate
                            pip install --upgrade pip
                            pip install django  # Or pip install -r requirements.txt

                            # 4. Run Migrations
                            python manage.py migrate --noinput

                            # 5. Restart the Server
                            # Kill whatever is running on port 8000 so we can restart
                            fuser -k 8000/tcp || true
                            
                            # Start server in background
                            BUILD_ID=dontKillMe nohup python manage.py runserver 0.0.0.0:8000 > django.log 2>&1 &
                        '
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Successfully deployed to http://${EC2_HOST}:8000"
        }
        failure {
            echo "Deployment failed. Check the Jenkins console output and django.log on the EC2."
        }
    }
}
