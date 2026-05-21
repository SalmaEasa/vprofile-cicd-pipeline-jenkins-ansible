def COLOR_MAP = [
    'SUCCESS': 'good', 
    'FAILURE': 'danger',
]
pipeline {
    
        agent any
    
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


    }

    stages{
        stage('Setup parameters') {
            steps {
                script { 
                    properties([
                        parameters([
                            string(
                                defaultValue: '', 
                                name: 'BUILD', 
                            ),
							string(
                                defaultValue: '', 
                                name: 'TIME', 
                            )
                        ])
                    ])
                }
            }
		}
        stage('Ansible Deploy to production') {
            steps {
                ansiblePlaybook(
                    playbook: 'ansible/site.yml',
                    inventory: 'ansible/prod.inventory',
                    installation: 'ansible',
                    colorized: true,
                    credentialsId: 'applogin-prod',
                    disableHostKeyChecking: true,                    
                    extraVars: [
                        USER: "${NEXUS_USER}",
                        PASS: "${NEXUS_PASS}",
                        nexusip: "${NEXUSIP}",
                        reponame: "${RELEASE_REPO}",
                        groupid: 'QA',
                        artifactid: 'vproapp',
                        build: "${env.BUILD}",
                        time: "${env.TIME}",
                        vprofile_version: "vproapp-${env.BUILD}-${env.TIME}.war"
                    ]
                )
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

