pipeline {
    agent any
     parameters {
        choice(
            name: 'Environment',
            choices: ['main', 'dev', 'qa'],
            description: 'Please Select env'
        )
    }
    tools {
        // Install the Maven version configured as "M3" and add it to the path.
        gradle "gradle"
    }
    environment {
        GIT_URL = "https://github.com/choudharyjayant/sample-java-project-jenkins-codedeploy.git"
        ARTIFACT_BUILD = "gradle-wrapper.jar"
        Zip_Name = "${BUILD_NUMBER}.zip"
        Application_name = "${params.Environment}-${JOB_NAME}"
        DeploymentGroup_Name = "DG-${params.Environment}-${JOB_NAME}"
        bucket_name = "${params.Environment}-${JOB_NAME}"
        SONAR_TOKEN = credentials('SONAR_TOKEN_GRADLE')
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', credentialsId: 'git-cred', url: 'https://github.com/choudharyjayant/gradle-java-hello.git'
                }
        }
        stage('verifying tools') {
            steps {
                sh ''' #! /bin/bash
                java --version
                gradle -v
                '''
            }
        }
        stage('Build') {
            steps {
                sh ''' #! /bin/bash
                #gradle init
                chmod +x gradlew
                ./gradlew clean build
                #--exclude-task test -i
                ./gradlew sonarqube -Dsonar.projectKey="gradle-sonar" -Dsonar.organization="jenkins-prefav" -Dsonar.host.url="https://sonarcloud.io" -Dsonar.login=$SONAR_TOKEN_GRADLE
                #3065346cb9f79c8721841c411d7ca9d0ae340ae7
                '''
            }
        }
	    stage ('Artifact') {
            steps {
                withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred-2', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                sh "echo this is ${env.AWS_ACCESS_KEY_ID}"
                sh "echo this is ${env.AWS_SECRET_ACCESS_KEY}"
                sh """ 
                #!/bin/bash
                #cd /var/lib/jenkins/workspace/${env.JOB_NAME}
		        zip -r ${env.Zip_Name} appspec.yml Dependency_Scripts build/libs/*.jar

		        #To push zip folder to s3 
                aws s3 cp ${env.Zip_Name}  s3://${env.bucket_name}/
                """
            }
        }
	}
        stage('Deploy') {
            steps {
                withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-cred-2', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                sh "echo this is ${env.AWS_ACCESS_KEY_ID}"
                sh "echo this is ${env.AWS_SECRET_ACCESS_KEY}"
                sh """ 
                #!/bin/bash

		        #to deploy on aws from s3 bucket
                aws deploy create-deployment --application-name ${env.Application_name} --deployment-group-name ${env.DeploymentGroup_Name} --deployment-config-name CodeDeployDefault.AllAtOnce --s3-location bucket=${env.bucket_name},bundleType=zip,key=${env.Zip_Name}    
                #echo Deployment Successfull
                """
                }
            }
        }
     }
    post {
        always {
            echo 'Stage is success'
        }
    }
}
