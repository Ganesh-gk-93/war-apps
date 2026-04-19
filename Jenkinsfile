pipeline {
    agent any

    triggers {
        pollSCM('* * * * *')    // checks every 1 minute
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Deploy') {
            steps {
                sh '''
                    chmod +x scripts/build.sh
                    ./scripts/build.sh
                '''
            }
        }
    }

    post {
        success { echo 'All 5 apps deployed!' }
        failure  { echo 'Build failed — check logs' }
    }
}