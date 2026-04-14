pipeline {
    agent any

    environment {
        // --- CONFIGURATION SECTION ---
        EC2_USER    = "ubuntu"
        EC2_HOST    = "3.16.1.1" 
        CRED_ID     = "ec2-ssh-private-key"
        PROJECT_DIR = "/home/ubuntu/pythonprojects/djangotutorial"
        REPO_URL    = "https://github.com/Tefect/DjangoExercise4.git"
        // ------------------------------
    }

    stages {
        stage('Deploy to EC2') {
            steps {
                script {
                    sshagent([CRED_ID]) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "
                            # 1. Update system and install Python/Git tools
                            sudo apt-get update && sudo apt-get install -y python3-venv python3-pip git

                            # 2. Ensure the parent directory exists
                            mkdir -p /home/ubuntu/pythonprojects

                            # 3. Clone if first time, otherwise Pull updates
                            if [ ! -d '${PROJECT_DIR}/.git' ]; then
                                echo 'Folder missing. Cloning repository...'
                                cd /home/ubuntu/pythonprojects
                                git clone ${REPO_URL} djangotutorial
                            fi

                            # 4. Move into project and get latest changes from MASTER
                            cd ${PROJECT_DIR}
                            git pull origin master

                            # 5. Create Virtual Environment if it doesn't exist
                            if [ ! -d 'comp314' ]; then
                                python3 -m venv comp314
                            fi

                            # 6. Activate venv and install dependencies
                            source comp314/bin/activate
                            pip install --upgrade pip
                            pip install -r requirements.txt

                            echo 'Deployment successful.'
                        "
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Code updated on EC2 (Master branch)."
        }
        failure {
            echo "FAILURE: Check the Jenkins console and your EC2 logs."
        }
    }
}
