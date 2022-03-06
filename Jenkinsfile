node{
   stage("CheckOutCode")
    {
        checkout([$class: 'GitSCM', branches: [[name: '*/docker-new']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/anithaannu/CI-CD-project.git']]])
    }
    
    stage("Build")
    {
        sh 'mvn install'
    }
    
   stage('Build Docker Image'){
     sh 'mkdir -p Docker-app/target'
     sh 'cp target/vprofile-v2.war Docker-app/target/'
     sh 'docker build -t anithaannu/vproappfix:$BUILD_ID Docker-app/'
     sh 'docker tag anithaannu/vproappfix:$BUILD_ID anithaannu/vproappfix:latest'
   }
   
  stage('Push Docker Image'){ 
   withDockerRegistry(credentialsId: 'dc743e29-888b-4cb9-8edd-8cac75ef228f', url: 'https://index.docker.io/v1/') {
    sh 'docker push anithaannu/vproappfix'
   }
 }
  stage('Deploy Docker Container into Docker Dev Server'){
     script {
     def dockerRun = 'docker run -p 8080:8080 -d --name vproapp anithaannu/vproappfix'
   sshagent(['6547a6af-1571-4af8-b2e8-811415a570aa']) {
    
    sh "scp -o StrictHostKeyChecking=no compose/* ubuntu@172.31.94.45:/home/ubuntu"
    sh "ssh -o StrictHostKeyChecking=no ubuntu@172.31.94.45 cd /home/ubuntu"
    sh "ssh -o StrictHostKeyChecking=no ubuntu@172.31.94.45 docker-compose up -d"
    }
     }
  }   
}
