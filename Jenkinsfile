// pipeline {
//     agent any
//     tools {
//         terraform 'terraform'
//     }
//     stages {
//         stage('Git init') {
//             steps {
//                 git credentialsId: 'your_token', url: 'https://github.com/777leyla/NewRepo.git'
//             }
//         }
//         stage('Terraform init') {
//             steps {
//                 sh 'terraform init -no-color'
//             }
//         }
//         stage('Terraform plan') {
//             steps {
//                 sh 'terraform plan -no-color'
//             }
//         }
//         stage('Terraform apply') {
//             input {
//                 message "Do you want to apply deployment?"
//             }
//             steps {
//                 sh 'terraform apply --auto-approve -no-color'
//             }
//         }
//     }
// }
// pipeline {
//     agent any
//     tools {
//         terraform 'terraform'
//     }
//     stages {
//         stage('Git init') {
//             steps {
//                 git credentialsId: 'your_token', url: 'https://github.com/777leyla/NewRepo.git'
//             }
//         }
//         stage('Terraform init') {
//             steps {
//                 sh 'terraform init -no-color'
//             }
//         }
//         stage('Terraform plan') {
//             steps {
//                 sh 'terraform plan -destroy -no-color'
//             }
//         }
//         stage('Terraform Destroy') {
//             input {
//                 message "Do you want to destroy deployment?"
//             }
//             steps {
//                 sh 'terraform destroy --auto-approve -no-color'
//             }
//         }
//     }
// }


pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh '''
                echo "Planning infrastructure"
                cd terraform
                terraform init
                terraform plan
                '''
            }
        }
    stage('Deploy') {
        steps {
            sh '''
            echo "Deploying infrustructure..."
            cd terraform
            terraform apply -auto-approve
            '''
        }
    }
    stage('finish') {
        steps {
            sh '''
            echo "pipeline finished"
            '''
        
        }
    }
    }
    post {
        always {
            deleteDir{}
        }
    }
}