pipeline {
    agent any {
        tools {
            java 'jdk17'
            maven 'mvn3'
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
                    scrip{
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
        }
    }
}