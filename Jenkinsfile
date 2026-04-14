pipeline {
    agent any

    environment {
        EC2_USER = "ubuntu"
        EC2_HOST = "3.16.1.1" 
        EC2_KEY_ID = 'ec2-ssh-private-key'
        // This is where the code will live on your server
        PROJECT_ROOT = "/home/ubuntu/pythonprojects"
        PROJECT_DIR = "/home/ubuntu/pythonprojects/djangotutorial"
    }

    stages {
        stage('Deploy & Setup on EC2') {
            steps {
                script {
                    sshagent (credentials: [EC2_KEY_ID]) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "
                            # 1. Install system dependencies (Fixes the venv error)
                            sudo apt-get update && sudo apt-get install -y python3-venv python3-pip

                            # 2. Ensure the parent directory exists
                            mkdir -p ${PROJECT_ROOT}

                            # 3. If project doesn't exist, clone it. Otherwise, pull updates.
                            if [ ! -d '${PROJECT_DIR}/.git' ]; then
                                echo 'Cloning repository for the first time...'
                                cd ${PROJECT_ROOT}
                                git clone https://github.com/Tefect/DjangoExercise4.git djangotutorial
                            fi

                            # 4. Navigate to project and update code
                            cd ${PROJECT_DIR}
                            git pull origin main

                            # 5. Setup and update Virtual Environment
                            python3 -m venv comp314
                            source comp314/bin/activate
                            pip install --upgrade pip
                            pip install -r requirements.txt
                            
                            # 6. Optional: Run migrations (if needed for Django)
                            # python3 manage.py migrate
                        "
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Successfully deployed to EC2!"
        }
        failure {
            echo "Deployment failed. Ensure your EC2 security group allows SSH and your .pem key is correct in Jenkins."
        }
    }
}
