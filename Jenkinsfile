def ImageName = ""
def ImageTag = ""
def Namespace = ""
def ChartName = ""

pipeline{
    agent { label 'jenkins-worker' }
    options {
        timeout(time: 1, unit: 'HOURS')
    }

    environment {
        ImageName = "tai"
      }

    stages{
        stage('Initiation') {
            steps{
                script {
                    def now = new Date()
                    ImageName = "192.168.7.80:10932/main-web"
                    ImageTag = "production" + now.format("yyMMdd", TimeZone.getTimeZone('Asia/Jakarta'))
                    ChartName = "main-web"
                    Namespace = "common"
                }
            }
        }
        stage('Build Docker Image') {
            steps{
                withDockerRegistry([ credentialsId: "jims-docker-admin", url: "http://192.168.7.80:10932/" ]) {
                    sh "docker build -t ${ImageName}:${ImageTag} -f src/configurations/prod-main-web.dockerfile ."
                }
            }
        }
        stage('Publish Docker Image') {
            steps{
                withDockerRegistry([ credentialsId: "jims-docker-admin", url: "http://192.168.7.80:10932/" ]) {
                    sh "docker push ${ImageName}:${ImageTag}"
                }
            }
        }
        stage('Clean Up Docker Image') {
            steps{
                withDockerRegistry([ credentialsId: "jims-docker-admin", url: "http://192.168.7.80:10932/" ]) {
                    sh "docker rmi ${ImageName}:${ImageTag} -f"
                }
            }
        }
        stage('Deploy To Kubernetes') {
            //agent { node { label 'jenkins-worker-1' } }
            steps{
                sh "ansible-playbook /root/playbooks/common/main-web/main-web-prod/initiation.yaml --user=root --extra-vars ChartName=${ChartName}"
                sh "ansible-playbook /root/playbooks/common/main-web/main-web-prod/execution.yaml --user=root --extra-vars ChartName=${ChartName} --extra-vars Namespace=${Namespace} --extra-vars ImageName=${ImageName} --extra-vars ImageTag=${ImageTag}"
            }
            post {
                success {
                    echo 'Code Deployed to K8s-Production'
                }
                failure {
                    echo 'Deployment Failed to K8s-Production'
                }
            }
        }
    }
}
