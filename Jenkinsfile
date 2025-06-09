// Define el pipeline con la sintaxis declarativa.
pipeline {
    // Especifica dónde se ejecutará el pipeline.
    agent any

    // Define variables de entorno que se usarán a lo largo del pipeline.
    // ¡Asegúrate de ajustar estos valores a tu configuración específica!
    environment {
        APP_NAME = 'react'                  // <--- ¡AJUSTA! Nombre de tu aplicación (ej: 'react', 'mi_app')
        CONTAINER_PORT = '80'               // <--- ¡AJUSTA! Puerto interno del contenedor Docker de tu app
        HOST_PORT = '8081'                  // <--- ¡AJUSTA! Puerto del servidor host que se mapeará al CONTAINER_PORT
                                            //        (ej: si accedes a tu app por http://tu_servidor:8081)

        // Variables para la conexión SSH remota (a través del plugin Publish Over SSH)
        SSH_SERVER_NAME = 'saserver'        // <--- ¡AJUSTA! Nombre del servidor configurado en Publish over SSH
        DEPLOY_USER = 'satest'              // <--- ¡AJUSTA! El usuario en el servidor remoto que tiene acceso a Docker

        // Path de la aplicación en el servidor remoto. Será '/APP_NAME'
        REMOTE_APP_DIR = "/home/satest/${APP_NAME}"     // <--- ¡AJUSTA SI QUIERES OTRA RUTA BASE QUE NO SEA LA RAÍZ!
                                            //        Ej: '/apps/react' si prefieres.
    }

    // Define las etapas (stages) del pipeline.
    stages {
        stage('Checkout Code (Jenkins Local)') {
            steps {
                echo "Clonando el repositorio Git en el workspace de Jenkins (estándar). Este código se enviará al servidor remoto."
                // Jenkins automáticamente clona el repositorio al inicio del job.
                // Este paso asegura que tengamos el código fuente en el workspace de Jenkins.
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
                                // Paso 1: Limpiar y crear el directorio remoto
                                sshTransfer(
                                    execCommand: """
                                        echo "--- Limpiando y creando directorio de la aplicación en el remoto ---"
                                        # Eliminar el directorio si ya existe para asegurar una copia limpia
                                        sudo -u satest rm -rf ${env.REMOTE_APP_DIR} || true
                                        # Crear el nuevo directorio
                                        sudo -u satest mkdir -p ${env.REMOTE_APP_DIR}
                                        # Asegurar que el usuario de despliegue (satest) sea el propietario y tenga permisos
                                        sudo -u satest chown ${env.DEPLOY_USER}:${env.DEPLOY_USER} ${env.REMOTE_APP_DIR}
                                        sudo -u satest chmod 755 ${env.REMOTE_APP_DIR}
                                        echo "Directorio remoto '${env.REMOTE_APP_DIR}' preparado."
                                    """
                                ),
                                // Paso 2: Copiar el código desde el workspace de Jenkins al servidor remoto
                                sshTransfer(
                                    sourceFiles: '**',          // Copia todos los archivos y directorios del workspace de Jenkins
                                    removePrefix: '.',          // Elimina el prefijo '.' para que no cree un '.'-directorio
                                    remoteDirectory: env.REMOTE_APP_DIR, // El directorio de destino en el servidor remoto
                                    execCommand: """
                                        echo "--- Código copiado al servidor remoto ---"
                                        # El 'execCommand' se ejecuta DESPUÉS de la transferencia de archivos
                                        # Puedes usarlo para verificar que los archivos están allí, si quieres
                                        sudo -u satest ls -la ${env.REMOTE_APP_DIR}
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

        // stage('Build Docker Image on Remote Server') {
        //     steps {
        //         script {
        //             echo "Construyendo la imagen Docker '${env.APP_NAME}:latest' en el servidor remoto '${env.SSH_SERVER_NAME}' como usuario '${env.DEPLOY_USER}'..."
        //             sshPublisher(publishers: [
        //                 sshPublisherDesc(
        //                     configName: env.SSH_SERVER_NAME,
        //                     transfers: [
        //                         sshTransfer(
        //                             execCommand: """
        //                                 echo "--- Inicio de construcción de imagen Docker ---"
        //                                 sudo -u ${env.DEPLOY_USER} docker build -t ${env.APP_NAME}:latest -f ${env.REMOTE_APP_DIR}/Dockerfile ${env.REMOTE_APP_DIR}
        //                                 echo "--- Fin de construcción de imagen Docker ---"
        //                             """
        //                         )
        //                     ]
        //                 )
        //             ])
        //             echo "Imagen Docker '${env.APP_NAME}:latest' construida en el servidor remoto."
        //         }
        //     }
        // }
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
            echo "¡Despliegue de '${env.APP_NAME}' fallido! 🔴 Hubo errores en el pipeline. Revisa la 'Console Output' cuidadosamente para depurar."
        }
    }
}
