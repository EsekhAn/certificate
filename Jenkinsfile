pipeline {
    agent any

    options {
        disableConcurrentBuilds()
        timeout(time: 90, unit: 'MINUTES')
    }

    parameters {
        choice(
            name: 'ACTION',
            choices: ['deploy', 'destroy'],
            description: 'deploy — создать/обновить stage; destroy — удалить инфраструктуру'
        )
        string(
            name: 'YANDEX_FOLDER_ID',
            defaultValue: '',
            description: 'ID каталога Yandex Cloud; если пусто — берётся YC_FOLDER_ID'
        )
    }

    stages {
        stage('Prepare') {
            steps {
                checkout scm
                script {
                    env.YC_FOLDER_ID = params.YANDEX_FOLDER_ID?.trim() ?: env.YC_FOLDER_ID
                    if (!env.YC_FOLDER_ID) {
                        error('Задайте YANDEX_FOLDER_ID или YC_FOLDER_ID')
                    }
                    env.IMAGE_TAG = env.BUILD_NUMBER
                }
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'yandex-ssh-key',
                    keyFileVariable: 'SSH_KEY',
                    passphraseVariable: 'SSH_PASSPHRASE'
                )]) {
                    sh 'ssh-keygen -y -P "$SSH_PASSPHRASE" -f "$SSH_KEY" > "$WORKSPACE/id_rsa.pub"'
                }
            }
        }

        stage('Terraform apply') {
            when { expression { params.ACTION == 'deploy' } }
            steps {
                script {
                    withYandexKey {
                        dir('terraform') {
                            sh 'terraform init -input=false'
                            sh '''
                                terraform apply -input=false -auto-approve \
                                  -var="folder_id=$YC_FOLDER_ID" \
                                  -var="ssh_public_key_path=$WORKSPACE/id_rsa.pub"
                            '''
                        }
                    }
                }
                script {
                    dir('terraform') {
                        env.BUILD_IP = sh(script: 'terraform output -raw build_public_ip', returnStdout: true).trim()
                        env.STAGE_IP = sh(script: 'terraform output -raw stage_public_ip', returnStdout: true).trim()
                        env.REGISTRY_IMAGE_URL = sh(script: 'terraform output -raw registry_image_url', returnStdout: true).trim()
                        env.APP_URL = sh(script: 'terraform output -raw app_url', returnStdout: true).trim()
                    }
                    env.APP_IMAGE = "${env.REGISTRY_IMAGE_URL}:${env.IMAGE_TAG}"
                    writeFile file: 'ansible/inventory/hosts.ini', text: """[build]
${env.BUILD_IP} ansible_user=ubuntu

[stage]
${env.STAGE_IP} ansible_user=ubuntu
"""
                    echo "Build node: ${env.BUILD_IP}"
                    echo "Stage node: ${env.STAGE_IP}"
                    echo "Image:      ${env.APP_IMAGE}"
                    echo "Stage URL:  ${env.APP_URL}"
                }
            }
        }

        stage('Build image') {
            when { expression { params.ACTION == 'deploy' } }
            steps {
                sshagent(credentials: ['yandex-ssh-key']) {
                    dir('ansible') {
                        sh """
                            ansible-playbook -i inventory/hosts.ini playbook.yml --limit build \
                              -e "app_image=${env.APP_IMAGE}" \
                              -e "registry_host=cr.yandex" \
                              -e "app_source_dir=${env.WORKSPACE}/app"
                        """
                    }
                }
            }
        }

        stage('Deploy to stage') {
            when { expression { params.ACTION == 'deploy' } }
            steps {
                sshagent(credentials: ['yandex-ssh-key']) {
                    dir('ansible') {
                        sh """
                            ansible-playbook -i inventory/hosts.ini playbook.yml --limit stage \
                              -e "app_image=${env.APP_IMAGE}" \
                              -e "registry_host=cr.yandex"
                        """
                    }
                }
            }
        }

        stage('Smoke test') {
            when { expression { params.ACTION == 'deploy' } }
            steps {
                sh '''
                    for i in $(seq 1 30); do
                      if curl -fsS --max-time 5 -o /dev/null "$APP_URL"; then
                        echo "Stage is reachable: $APP_URL"
                        exit 0
                      fi
                      echo "Attempt $i/30: stage is not ready"
                      sleep 10
                    done
                    echo "Stage did not respond: $APP_URL"
                    exit 1
                '''
            }
        }

        stage('Terraform destroy') {
            when { expression { params.ACTION == 'destroy' } }
            steps {
                script {
                    withYandexKey {
                        dir('terraform') {
                            sh 'terraform init -input=false'
                            sh '''
                                terraform destroy -input=false -auto-approve \
                                  -var="folder_id=$YC_FOLDER_ID" \
                                  -var="ssh_public_key_path=$WORKSPACE/id_rsa.pub"
                            '''
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Готово: ${env.APP_URL ?: 'инфраструктура удалена'}"
        }
        failure {
            echo "Пайплайн упал: ${env.BUILD_URL}"
        }
    }
}

def withYandexKey(Closure body) {
    withCredentials([file(credentialsId: 'yandex-cloud-key', variable: 'YC_SERVICE_ACCOUNT_KEY_FILE')]) {
        body()
    }
}
