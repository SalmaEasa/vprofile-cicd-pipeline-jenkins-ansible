def buildNumber = Jenkins.instance.getItem('cicd-jenkins-bean-stage').lastSuccessfulBuild.number
def COLOR_MAP = [
    'SUCCESS': 'good', 
    'FAILURE': 'danger',
]
pipeline {
    
        agent any

    tools {
        jdk "JDK11"
        maven "MAVEN3.9"
    }
    
    environment{

        ARTIFACT_NAME ="vprofile-v${buildNumber}.war"
        AWS_S3_BUCKET = "vprofile-cicd-bean"
        AWS_EB_APP_NAME = "vpro-beanstalk"
        AWS_EB_ENVIRONMENT = "Vpro-beanstalk-prod-env"
        AWS_EB_APP_VERSION = "${buildNumber}"

    }

    stages{

        stage('Deploy to Prod Bean'){
            steps{
                withAWS(credentials: 'awsbeancreds', region: 'us-east-1'){
                sh 'aws elasticbeanstalk update-environment --application-name $AWS_EB_APP_NAME --environment-name $AWS_EB_ENVIRONMENT --version-label $AWS_EB_APP_VERSION'                    
                    }
            }
        }
    }

    post {
        always {
            echo 'Slack Notifications.'
            slackSend channel: '#jenkinscicd',
                color: COLOR_MAP[currentBuild.currentResult],
                message: "*${currentBuild.currentResult}:* Job ${env.JOB_NAME} build ${env.BUILD_NUMBER} \n More info at: ${env.BUILD_URL}"
        }
        
    }
}

