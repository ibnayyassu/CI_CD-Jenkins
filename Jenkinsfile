pipeline {
    agent any
    environment {
        ARTIFACTORY_URL = "https://trialu47lau.jfrog.io/artifactory"
        ARTIFACTORY_REPO = "tf--terraform-modules-local"
        NAMESPACE = "derrickweil"
        MODULE_NAME = "your-module-name"
        VERSION = "your-version"
    }
    stages {
        stage('Install JFrog CLI') {
            steps {
                sh '''
                    if ! command -v jfrog &> /dev/null; then
                      echo "JFrog CLI not found. Installing..."
                      curl -fL https://getcli.jfrog.io | sh
                      chmod +x jfrog
                      sudo mv jfrog /usr/local/bin/ || echo "Running with local binary"
                    else
                      echo "JFrog CLI already installed."
                    fi
                '''
            }
        }
        stage('Build Artifact') {
            steps {
                // Replace with your actual build commands that create the artifact.
                sh 'echo "Building artifact..."'
                // For testing purposes, you might simulate an artifact:
                sh 'mkdir -p dist && echo "dummy content" > dist/test.zip'
            }
        }
        stage('Upload Artifact') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'artifactory-creds', 
                                                  usernameVariable: 'ARTIFACTORY_USER', 
                                                  passwordVariable: 'ARTIFACTORY_API_KEY')]) {
                    sh '''
                        jfrog rt upload "dist/*.zip" "${ARTIFACTORY_REPO}/${NAMESPACE}/${MODULE_NAME}/${VERSION}/" \
                          --url="${ARTIFACTORY_URL}" --user="${ARTIFACTORY_USER}" --apikey="${ARTIFACTORY_API_KEY}"
                    '''
                }
            }
        }
    }
}


run this first on the server
# curl -fL https://getcli.jfrog.io | sh
# chmod +x jfrog
# sudo mv jfrog /usr/local/bin/
