pipeline {
    agent any

    environment {
        // --- CONFIGURATION ---
        EC2_USER    = "ubuntu"
        EC2_HOST    = "3.16.1.1" 
        CRED_ID     = "ec2-ssh-private-key"
        PROJECT_DIR = "/home/ubuntu/pythonprojects/djangotutorial"
        REPO_URL    = "https://github.com/Tefect/DjangoExercise4.git"
    }

    stages {
        stage('Clean Deploy & Start Server') {
            steps {
                script {
                    sshagent([CRED_ID]) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} "
                            # 1. Update system and install necessary tools
                            sudo apt-get update && sudo apt-get install -y python3-venv python3-pip git

                            # 2. Kill any old Django processes running on port 8000
                            sudo fuser -k 8000/tcp || true

                            # 3. Fresh Clone: Delete old folder and re-download
                            sudo rm -rf ${PROJECT_DIR}
                            mkdir -p /home/ubuntu/pythonprojects
                            cd /home/ubuntu/pythonprojects
                            git clone ${REPO_URL} djangotutorial

                            # 4. Setup Environment
                            cd ${PROJECT_DIR}
                            python3 -m venv comp314
                            source comp314/bin/activate
                            
                            # 5. Install Dependencies and Migrate
                            pip install --upgrade pip
                            pip install -r requirements.txt
                            python3 manage.py migrate --noinput

                            # 6. Start the server in the background
                            # '0.0.0.0:8000' makes it public. 
                            # 'nohup' and '&' keep it running after Jenkins leaves.
                            BUILD_ID=dontKillMe nohup python3 manage.py runserver 0.0.0.0:8000 > django.log 2>&1 &
                            
                            sleep 2
                            echo 'Server started at http://${EC2_HOST}:8000'
                        "
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "SUCCESS: Webpage should now be live at http://3.16.1.1:8000"
        }
        failure {
            echo "FAILURE: Deployment failed. Check Jenkins logs for SSH or Python errors."
        }
    }
}
