pipeline {
  agent any

  environment {
    IMAGE_NAME = "cicd-dev"
    REGISTRY = "registry.mycompany.com"
    VENV_DIR = "venv"
  }

  stages {
    stage('Checkout') {
      steps {
        git 'https://github.com/leerizza/cicd-dev.git'
      }
    }

    stage('Setup Python Env') {
      steps {
        sh '''
          python3 -m venv $VENV_DIR
          . $VENV_DIR/bin/activate
          pip install --upgrade pip
          pip install pytest dbt-core
        '''
      }
    }

    stage('Test') {
      steps {
        sh '''
          . $VENV_DIR/bin/activate
          pytest tests/
        '''
      }
    }

    stage('DBT Build & Test') {
      steps {
        sh '''
          . $VENV_DIR/bin/activate
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
          sh '''
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin $REGISTRY
            docker push $REGISTRY/$IMAGE_NAME:$BUILD_NUMBER
          '''
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
