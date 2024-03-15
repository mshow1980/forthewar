pipeline {
    agent any 
        tools {
            maven 'mvn3'
            jdk 'jdk17'
        }
        environment{
            APP_NAME = "rforthewar"
            DOCKER_USER = "mshow1980"
            RELEASE_NUMBER = "1.0.0"
            REGISTRY_CREDS = 'Docker-login'
            IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
            IMAGE_TAGE = "${RELEASE_NUMBER}-${BUILD_NUMBER}"
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
                        withSonarQubeEnv(credentialsId: 'SOnar-token') {
                            sh 'mvn sonar:sonar'
                        }
                    }
                }
            }
            stage('Quality Gate'){
                steps{
                    script{
                        waitForQualityGate abortPipeline: false, credentialsId: 'SOnar-token'
                    }
                }
            }
            stage('Build Docker Image'){
                steps{
                    script{
                        withDockerRegistry(credentialsId: 'Docker-login') {
                            docker_image = docker.build "${IMAGE_NAME}"
                        }
                        withDockerRegistry(credentialsId: 'Docker-login') {
                            docker_image.push(${BUILD_NUMBER})
                            docker_image.push('lastest')
                        }
                    }
                }
            }
        }
    }
