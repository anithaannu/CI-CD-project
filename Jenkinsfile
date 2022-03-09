#!/usr/bin/env groovy

pipeline {
    agent any
    
    stages {
        
        stage('build app') {
            steps {
               script {
                  sh 'mvn install'
               }
            }
        }
        
       stage('Build Docker Image') {
            steps {
               script {
                  sh 'mkdir -p Docker-app/target'
                  sh 'cp target/vprofile-v2.war Docker-app/target/'
                  sh 'docker build -t anithaannu/vproappfix:$BUILD_ID Docker-app/'
                  sh 'docker tag anithaannu/vproappfix:$BUILD_ID anithaannu/vproappfix:latest'
               }
            }
        } 
        
        stage('Push Docker Image') {
            steps {
               script {
                  withDockerRegistry(credentialsId: 'dc743e29-888b-4cb9-8edd-8cac75ef228f', url: 'https://index.docker.io/v1/') {
                  sh 'docker push anithaannu/vproappfix'
                  sh 'docker rmi anithaannu/vproappfix:$BUILD_ID'
                 }
               }
            }
        } 
        
        stage('provision server') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
            }
            steps {
                script {
                    dir('terraform') {
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        EC2_PUBLIC_IP = sh(
                            script: "terraform output ec2_public_ip",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }
           
        stage('deploy') {
            environment {
                IMAGE_NAME = 'anithaannu/vproappfix:latest'
            }        
            steps {
                script {
                   echo "waiting for EC2 server to initialize" 
                   sleep(time: 30, unit: "SECONDS") 

                   echo 'deploying docker image to EC2...'
                   echo "${EC2_PUBLIC_IP}"

                   def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                   def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"

                   sshagent(['6547a6af-1571-4af8-b2e8-811415a570aa']) {
                       sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user"
                       sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                       sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                   }
                }
            }
        }

        
        
    }
}
