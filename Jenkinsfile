pipeline {
  agent {
    docker {
      image 'python:3.10'
    }
  }

  environment {
    IMAGE_NAME = "cicd-dev"
    REGISTRY = "registry.mycompany.com"
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/leerizza/cicd-dev.git'
      }
    }

  stage('Install Python') {
    steps {
        sh '''
          apt-get update
          apt-get install -y python3 python3-venv python3-pip
        '''
      }
    }

    stage('Test') {
      steps {
        sh '''
          pip install pytest
          pytest tests/
        '''
      }
    }

    stage('DBT Build & Test') {
      steps {
        sh '''
          pip install dbt-core
          dbt run
          dbt test
        '''
      }
    }

    stage('Build Docker Image') {
      steps {
        sh 'docker build -t $REGISTRY/$IMAGE_NAME:$BUILD_NUMBER .'
      }
    }

    stage('Push to Registry') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-creds', passwordVariable: 'DOCKER_PASS', usernameVariable: 'DOCKER_USER')]) {
          sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin $REGISTRY'
          sh 'docker push $REGISTRY/$IMAGE_NAME:$BUILD_NUMBER'
        }
      }
    }

    stage('Deploy to Staging') {
      steps {
        sh 'docker run --env-file config/staging.env $REGISTRY/$IMAGE_NAME:$BUILD_NUMBER'
      }
    }
  }

  post {
    failure {
      echo '⚠️ Build or deploy failed. Rolling back...'
    }
  }
}
