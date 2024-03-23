pipeline {
    agent any 
        tools {
            maven 'mvn3'
            jdk 'jdk17'
        }
        environment{
            APP_NAME = "thewargame"
            DOCKER_USER = "mshow1980"
            RELEASE_NUMBER = "1.0.0"
            REGISTRY_CREDS = 'docker-login'
            IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
            IMAGE_TAGE = "${RELEASE_NUMBER}-${BUILD_NUMBER}"
            JENKINS-API-TOKEN = credentials('JENKINS-API-TOKEN')
        }
        stages {
            stage('Clean WorkSpace'){
                steps{
                    script{
                        cleanWs()
                    }
                }
            }
            stage('Checkout SCM'){
                steps{
                    script{
                        checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/mshow1980/forthewar.git']])
                    }
                }
            }
            stage('maven clean install'){
                steps{
                    script{
                        sh 'mvn clean package'
                    }
                }
            }
            stage('OWASP Dependency-Check Vulnerabilities'){
                steps{
                    script{
                    dependencyCheck additionalArguments: ''' 
                    -o "./" 
                    -s "./"
                    -f "ALL" 
                    --prettyPrint''', odcInstallation: 'OWASP-DC'
                    dependencyCheckPublisher pattern: 'dependency-check-report.xml'
                    }
                }
            }
            stage('Test Application'){
                steps{
                    script{
                        sh 'mvn test'
                    }
                }
            }
            stage('TRIVY FS CODE SCAN'){
                steps{
                    script{
                        sh 'trivy fs .'
                    }
                }
            }
            stage('SonarQube Analysis'){
                steps{
                    script{
                        withSonarQubeEnv(credentialsId: 'SOnar-Token') {
                            sh 'mvn sonar:sonar'
                        }
                    }
                }
            }
            stage('Quality Gate'){
                steps{
                    script{
                        waitForQualityGate abortPipeline: false, credentialsId: 'SOnar-Token'
                    }
                }
            }
            stage('Build Docker Image'){
                steps{
                    script{
                        withDockerRegistry(credentialsId: 'docker-login') {
                            docker_image = docker.build "${IMAGE_NAME}"
                        }
                        withDockerRegistry(credentialsId: 'docker-login') {
                            docker_image.push("${BUILD_NUMBER}")
                            docker_image.push('latest')
                        }
                    }
                }
            }
            stage('TRIVY FS IMAGE SCAN'){
                steps{
                    script{
                    sh 'trivy image "${IMAGE_NAME}":latest'
                    }
                }
            }
            stage('Updating Deployment File'){
                steps{
                    script{
                        sh "curl -v -k --user admin:${JENKINS-API-TOKEN} -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' 'http://3.95.27.46:8080/job/gitops-deployment/buildWithParameters?token=SCION_SCOPE'"
                    }
                }
            }
        }
    }
