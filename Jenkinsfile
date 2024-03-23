pipeline{
    agent any 
    environment{
        APP_NAME = "forthewar"
        RELEASE = "1.0.0"
        GIT_USERNAME = "mshow1980"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
        REGISTRY_CREDS  = "JENKINS-API-TOKEN"


    }
    stages{
        stage('Clean Workspace') {
            steps{
                script{
                    cleanWs()
                }
            }
        }
        stage('Checkout SCM'){
            steps{
                script{
			checkout scmGit(branches: [[name: '*/deployment']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/mshow1980/forthewar.git']])
                }
            }
        }
        stage('Updating Deployment Manifest'){
            steps{
                script{
                        sh """
                        git config --global user.name "mshow1980"
                        git config --global user.email "mshow1980@aol.com"
                        git checkout deployment
                        cat deployment.yaml
                        sed -i 's/${APP_NAME}.*/${APP_NAME}:${IMAGE_TAG}/g' deployment.yaml
                        cat deployment.yaml
                        git add deployment.yaml
                        git commit -m 'Updated the deployment file'
                        """
                    }
                    withCredentials([gitUsernamePassword(credentialsId: 'git-token', gitToolName: 'Default')]) {
                    sh 'git push https://github.com/mshow1980/forthewar.git deployment '
                }
            }
        }
    }
}
