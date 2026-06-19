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

        SNAP_REPO = 'vprofile-snapshot'
		NEXUS_USER = 'admin'
		NEXUS_PASS = credentials('nexuspass')
		RELEASE_REPO = 'vprofile-release'
		CENTRAL_REPO = 'vpro-maven-central'
		NEXUSIP = '172.31.0.175'
		NEXUSPORT = '8081'
		NEXUS_GRP_REPO = 'vprofile-group'
        NEXUS_LOGIN = 'nexuslogin'        
        SONARSERVER = 'sonarserver'
        SONARSCANNER = 'sonarscanner'
        ARTIFACT_NAME ="vprofile-v${BUILD_ID}.war"
        AWS_S3_BUCKET = "vprofile-cicd-bean"
        AWS_EB_APP_NAME = "vpro-beanstalk"
        AWS_EB_ENVIRONMENT = "Vpro-bean-env"
        AWS_EB_APP_VERSION = "${BUILD_ID}"


    }

    stages{
        stage('Build'){
            steps{
                sh 'mvn -s settings.xml -DskipTests install'
            }
            post{
                success {
                    echo "Now Archiving."
                    archiveArtifacts artifacts: '**/*.war'
                }
            }
        }
        
        stage('Test'){
            steps{
                sh 'mvn -s settings.xml test'
            }
        }

        stage('Sonar Analysis') {
            environment {
                scannerHome = tool "${SONARSCANNER}"
            }
            steps {
                withSonarQubeEnv("${SONARSERVER}") {
                    sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=vprofile \
                    -Dsonar.projectName=vprofile \
                    -Dsonar.projectVersion=1.0 \
                    -Dsonar.sources=src/ \
                    -Dsonar.java.binaries=target/test-classes/com/visualpathit/account/controllerTest/ \
                    -Dsonar.junit.reportsPath=target/surefire-reports/ \
                    -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                    -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    // Parameter indicates whether to set pipeline to UNSTABLE if Quality Gate fails
                    // true = set pipeline to UNSTABLE, false = don't
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage("UploadArtifcat"){
            steps{
                nexusArtifactUploader(
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    nexusUrl: "${NEXUSIP}:${NEXUSPORT}",
                    groupId: 'QA',
                    version: "${env.BUILD_ID}-${env.BUILD_TIMESTAMP}",
                    repository: "${RELEASE_REPO}",
                    credentialsId: "${NEXUS_LOGIN}",
                    artifacts: [
                        [artifactId: 'vproapp',
                        classifier: '',
                        file: 'target/vprofile-v2.war',
                        type: 'war']
                    ]
                )
            }
        }

        stage('Ansible Deploy to staging') {
            steps {
                ansiblePlaybook(
                    playbook: 'ansible/site.yml',
                    inventory: 'ansible/stage.inventory',
                    installation: 'ansible',
                    colorized: true,
                    credentialsId: 'applogin',
                    disableHostKeyChecking: true,                    
                    extraVars: [
                        USER: "${NEXUS_USER}",
                        PASS: "${NEXUS_PASS}",
                        nexusip: "${NEXUSIP}",
                        reponame: "${RELEASE_REPO}",
                        groupid: 'QA',
                        artifactid: 'vproapp',
                        build: "${env.BUILD_ID}",
                        time: "${env.BUILD_TIMESTAMP}",
                        vprofile_version: "vproapp-${env.BUILD_ID}-${env.BUILD_TIMESTAMP}.war"
                    ]
                )
            }
        }

        stage('Deploy to Stage Bean'){
            steps{
                withAWS(credentials: 'awsbeancreds', region: 'us-east-1'){
                sh 'aws s3 cp ./target/vprofile-v2.war s3://$AWS_S3_BUCKET/$ARTIFACT_NAME'
                sh 'aws elasticbeanstalk create-application-version --application-name $AWS_EB_APP_NAME --version-label $AWS_EB_APP_VERSION --source-bundle S3Bucket=$AWS_S3_BUCKET,S3Key=$ARTIFACT_NAME'
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

