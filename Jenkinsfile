pipeline {
    agent any

    stages {
        stage('Clone') {
            steps {
                git "https://github.com/Tefect/DjangoExercise4"
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                sudo apt update
                sudo apt install python3-pip -y
                pip3 install django
                '''
            }
        }

        stage('Run Server') {
            steps {
                sh '''
                python3 manage.py migrate
                nohup python3 manage.py runserver 0.0.0.0:8000 &
                '''
            }
        }
    }
}