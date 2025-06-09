// Define el pipeline con la sintaxis declarativa.
pipeline {
    // Especifica dónde se ejecutará el pipeline.
    agent any

    // Define variables de entorno que se usarán a lo largo del pipeline.
    // ¡Asegúrate de ajustar estos valores a tu configuración específica!
    environment {
        APP_NAME = 'react'                  // <--- ¡AJUSTA! Nombre de tu aplicación
        CONTAINER_PORT = '80'               // <--- ¡AJUSTA! Puerto interno del contenedor Docker de tu app
        HOST_PORT = '8081'                  // <--- ¡AJUSTA! Puerto del servidor host que se mapeará al CONTAINER_PORT

        # Variables para la conexión SSH remota (a través del plugin Publish Over SSH)
        SSH_SERVER_NAME = 'saserver'        // <--- ¡AJUSTA! Nombre del servidor configurado en Publish over SSH
        DEPLOY_USER = 'satest'              // <--- ¡AJUSTA! El usuario en el servidor remoto que tiene acceso a Docker

        # OJO: Necesitas saber el usuario y grupo con el que Jenkins se conecta vía SSH para la copia.
        # Por ejemplo, si en la configuración de 'saserver' usas 'ubuntu' como Username:
        SSH_CONNECT_USER = 'e06911'         // <--- ¡AJUSTA! El usuario con el que Jenkins se conecta por SSH a 'saserver'
        SSH_CONNECT_GROUP = 'e06911'        // <--- ¡AJUSTA! El grupo principal de ese usuario en el servidor remoto
                                            //        (a menudo es el mismo nombre que el usuario)

        # Path de la aplicación en el servidor remoto.
        # Usamos /home/${DEPLOY_USER} para que esté en el home del usuario 'satest'
        REMOTE_APP_DIR = "/home/${DEPLOY_USER}/${APP_NAME}" // <--- ¡AJUSTA si quieres otra ruta base!
    }

    // Define las etapas (stages) del pipeline.
    stages {
        stage('Checkout Code (Jenkins Local)') {
            steps {
                echo "Clonando el repositorio Git en el workspace de Jenkins (estándar). Este código se enviará al servidor remoto."
                // Jenkins automáticamente clona el repositorio al inicio del job.
                // Esta etapa asegura que tengamos el código fuente en el workspace de Jenkins.
            }
        }

        stage('Prepare Remote Environment and Copy Code') {
            steps {
                script {
                    echo "Preparando directorio remoto '${env.REMOTE_APP_DIR}' y copiando código a '${env.SSH_SERVER_NAME}'..."
                    sshPublisher(publishers: [
                        sshPublisherDesc(
                            configName: env.SSH_SERVER_NAME,
                            transfers: [
                                # Paso 1: Limpiar y crear el directorio remoto con el usuario de la CONEXIÓN SSH.
                                # Esto asegura que el usuario que va a COPIAR tenga permisos sobre el directorio.
                                sshTransfer(
                                    execCommand: """
                                        echo "--- Limpiando y creando directorio de la aplicación en el remoto ---"
                                        # Eliminar el directorio si ya existe para asegurar una copia limpia
                                        # Ejecutado con sudo por el usuario de la conexión (ej: ubuntu)
                                        sudo rm -rf ${env.REMOTE_APP_DIR} || true
                                        # Crear el nuevo directorio
                                        sudo mkdir -p ${env.REMOTE_APP_DIR}
                                        # Asegurar que el usuario de la CONEXIÓN SSH sea el propietario
                                        # para que pueda escribir en él durante la transferencia.
                                        sudo chown ${env.SSH_CONNECT_USER}:${env.SSH_CONNECT_GROUP} ${env.REMOTE_APP_DIR}
                                        sudo chmod 755 ${env.REMOTE_APP_DIR}
                                        echo "Directorio remoto '${env.REMOTE_APP_DIR}' preparado."
                                    """
                                ),
                                # Paso 2: Copiar el código desde el workspace de Jenkins al servidor remoto.
                                # Esta operación de copia se hace con los permisos del SSH_CONNECT_USER.
                                sshTransfer(
                                    sourceFiles: '**',          // Copia todos los archivos y directorios del workspace de Jenkins
                                    removePrefix: '.',          // Elimina el prefijo '.' para que no cree un '.'-directorio
                                    remoteDirectory: env.REMOTE_APP_DIR, // El directorio de destino en el servidor remoto
                                    execCommand: """
                                        echo "--- Código copiado al servidor remoto ---"
                                        # Este execCommand se ejecuta DESPUÉS de la transferencia de archivos.
                                        # Verifica que los archivos se copiaron correctamente como el usuario de la conexión.
                                        ls -la ${env.REMOTE_APP_DIR}
                                        echo "--- Fin de la copia de código ---"
                                    """
                                )
                            ]
                        )
                    ])
                    echo "Código copiado exitosamente a '${env.REMOTE_APP_DIR}' en el servidor remoto."
                }
            }
        }

        stage('Build Docker Image on Remote Server') {
            steps {
                script {
                    echo "Construyendo la imagen Docker '${env.APP_NAME}:latest' en el servidor remoto '${env.SSH_SERVER_NAME}' como usuario '${env.DEPLOY_USER}'..."
                    sshPublisher(publishers: [
                        sshPublisherDesc(
                            configName: env.SSH_SERVER_NAME,
                            transfers: [
                                sshTransfer(
                                    execCommand: """
                                        echo "--- Inicio de construcción de imagen Docker ---"
                                        # ¡IMPORTANTE! Cambia la propiedad de los archivos copiados a DEPLOY_USER (satest)
                                        # ANTES de que Docker necesite acceder a ellos.
                                        sudo chown -R ${env.DEPLOY_USER}:${env.DEPLOY_USER} ${env.REMOTE_APP_DIR}
                                        
                                        # Cambiar al directorio donde se copió tu Dockerfile y el código fuente
                                        cd ${env.REMOTE_APP_DIR} || exit 1 # Sale si no puede cambiar de directorio
                                        
                                        # Ejecutar docker build como el usuario con acceso a Docker
                                        sudo -u ${env.DEPLOY_USER} docker build -t ${env.APP_NAME}:latest .
                                        echo "--- Fin de construcción de imagen Docker ---"
                                    """
                                )
                            ]
                        )
                    ])
                    echo "Imagen Docker '${env.APP_NAME}:latest' construida en el servidor remoto."
                }
            }
        }

        stage('Deploy Docker Container on Remote Server') {
            steps {
                script {
                    echo "Desplegando el contenedor Docker '${env.APP_NAME}-container' en el servidor remoto '${env.SSH_SERVER_NAME}' como usuario '${env.DEPLOY_USER}'..."
                    sshPublisher(publishers: [
                        sshPublisherDesc(
                            configName: env.SSH_SERVER_NAME,
                            transfers: [
                                sshTransfer(
                                    execCommand: """
                                        echo "--- Inicio de despliegue de contenedor ---"
                                        # Detener y eliminar el contenedor antiguo si existe (|| true evita que el script falle)
                                        echo "Intentando detener contenedor antiguo '${APP_NAME}-container'..."
                                        sudo -u ${env.DEPLOY_USER} docker stop ${APP_NAME}-container || true
                                        echo "Intentando eliminar contenedor antiguo '${APP_NAME}-container'..."
                                        sudo -u ${env.DEPLOY_USER} docker rm ${APP_NAME}-container || true
                                        
                                        # Lanzar el nuevo contenedor con la imagen recién construida
                                        echo "Lanzando nuevo contenedor '${APP_NAME}-container'..."
                                        sudo -u ${env.DEPLOY_USER} docker run -d --name ${APP_NAME}-container -p ${HOST_PORT}:${CONTAINER_PORT} ${APP_NAME}:latest
                                        echo "--- Contenedor nuevo levantado ---"
                                        
                                        # Opcional: Pausa breve para que el contenedor inicie y muestre los últimos logs
                                        # echo "Esperando 5 segundos para que el contenedor inicie completamente..."
                                        # sleep 5
                                        # echo "Últimos logs del contenedor '${APP_NAME}-container':"
                                        # sudo -u ${env.DEPLOY_USER} docker logs ${APP_NAME}-container --tail 10
                                    """
                                )
                            ]
                        )
                    ])
                    echo "Contenedor '${APP_NAME}-container' desplegado en el servidor remoto."
                }
            }
        }

        stage('Post-Deployment Verification (Optional)') {
            steps {
                script {
                    echo "Realizando una verificación post-despliegue en el servidor remoto..."
                    sshPublisher(publishers: [
                        sshPublisherDesc(
                            configName: env.SSH_SERVER_NAME,
                            transfers: [
                                sshTransfer(
                                    execCommand: """
                                        echo "--- Verificación de contenedor corriendo ---"
                                        # Muestra el estado del contenedor recién desplegado
                                        sudo -u ${env.DEPLOY_USER} docker ps -f "name=${APP_NAME}-container"
                                        echo "--- Fin verificación ---"
                                    """
                                )
                            ]
                        )
                    ])
                    echo "Verificación simple completada. Revisa la consola para el estado del contenedor."
                }
            }
        }
    }

    // Bloque 'post' para definir acciones que se ejecutarán al finalizar el pipeline.
    post {
        always {
            echo "Pipeline de despliegue finalizado. Revisa la 'Console Output' para todos los detalles del proceso."
        }
        success {
            echo "¡Despliegue de '${env.APP_NAME}' exitoso! 🎉 La aplicación debería estar accesible en tu servidor remoto en el puerto ${env.HOST_PORT}."
        }
        failure {
            echo "¡Despliegue de '${APP_NAME}' fallido! 🔴 Hubo errores en el pipeline. Revisa la 'Console Output' cuidadosamente para depurar."
        }
    }
}
