//Note: I have added extra information in shared libraries stored in github repos for every function calling here.
@Library('Shared') _
pipeline {
    agent any
    
    environment{
        SONAR_HOME = tool "Sonar" // Using the Sonar tool for code scanning
    }
    // When we will run the build so it will ask user to enter tags. it will show two input boxes
    parameters {
        string(name: 'FRONTEND_DOCKER_TAG', defaultValue: '', description: 'Setting docker image for latest push')  
        string(name: 'BACKEND_DOCKER_TAG', defaultValue: '', description: 'Setting docker image for latest push')
    }
    
    stages {
        stage("Validate Parameters") {
            steps {
                script {
                    if (params.FRONTEND_DOCKER_TAG == '' || params.BACKEND_DOCKER_TAG == '') {
                        error("FRONTEND_DOCKER_TAG and BACKEND_DOCKER_TAG must be provided.") // if user didn't pass frontend, backend tag so it will throw an error
                    }
                }
            }
        }
        stage("Workspace cleanup"){
            steps{
                script{
                    cleanWs() // it will clean old build workspace and artifacts
                }
            }
        }
        
        stage('Git: Code Checkout') {
            steps {
                script{
                    code_checkout("https://github.com/Ramakantvats/Wanderlust-Mega-Project.git","main")
                }
            }
        }
        
        stage("Trivy: Filesystem scan"){
            steps{
                script{
                    trivy_scan() //scans packages used in your code , docker images , terraform misconfiguration , kubernetes misconfiguration.
                }
            }
        }

        stage("OWASP: Dependency check"){
            steps{
                script{
                    owasp_dependency() // It will check the libraries your application is using.
                }
            }
        }
        
        stage("SonarQube: Code Analysis"){
            steps{
                script{
                    sonarqube_analysis("Sonar","wanderlust","wanderlust") //It checks you code logic , overall code.
                }
            }
        }
        
        stage("SonarQube: Code Quality Gates"){
            steps{
                script{
                    sonarqube_code_quality()// rules should be pass by your code to complete the deployment
                }
            }
        }

        //below is the parallel stage means both stages inside the parallel barces{} will execute simultaneously to update backend and frontend scripts.
        stage('Exporting environment variables') {
            parallel{
                stage("Backend env setup"){
                    steps {
                        script{
                            dir("Automations"){
                                sh "bash updatebackendnew.sh"
                            }
                        }
                    }
                }
                
                stage("Frontend env setup"){
                    steps {
                        script{
                            dir("Automations"){
                                sh "bash updatefrontendnew.sh"
                            }
                        }
                    }
                }
            }
        }
        //Creating docker frontend and backend images
        stage("Docker: Build Images"){
            steps{
                script{
                        dir('backend'){
                            docker_build("wanderlust-backend-beta","${params.BACKEND_DOCKER_TAG}","ramakantvats")
                        }
                    
                        dir('frontend'){
                            docker_build("wanderlust-frontend-beta","${params.FRONTEND_DOCKER_TAG}","ramakantvats")
                        }
                }
            }
        }
        //Pushing the docker images to dockerhub
        stage("Docker: Push to DockerHub"){
            steps{
                script{
                    docker_push("wanderlust-backend-beta","${params.BACKEND_DOCKER_TAG}","ramakantvats") 
                    docker_push("wanderlust-frontend-beta","${params.FRONTEND_DOCKER_TAG}","ramakantvats")
                }
            }
        }
    }
    post{
        success{ // if this pipeline executed successfully so it will store artiface.
            archiveArtifacts artifacts: '*.xml', followSymlinks: false
            build job: "Wanderlust-CD", parameters: [  // Then, it will trigger new jenkins job named (Wanderlust-CD) a continuous delivery job
                string(name: 'FRONTEND_DOCKER_TAG', value: "${params.FRONTEND_DOCKER_TAG}"),
                string(name: 'BACKEND_DOCKER_TAG', value: "${params.BACKEND_DOCKER_TAG}")
            ]
        }
    }
}
