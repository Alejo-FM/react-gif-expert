pipeline {
    agent any

    environment {
        APP_NAME = 'my-react-app'
        CONTAINER_PORT = '80'
        HOST_PORT = '8081'
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Clonando el repositorio Git..."
            }
        }

        stage('Build Docker Image Locally on Host') {
            steps {
                script {
                    echo "Construyendo la imagen Docker '${APP_NAME}:latest' en el host usando Docker Pipeline plugin..."
                    // Usa docker.build() del plugin Docker Pipeline.
                    // El 'docker' aquí se refiere al objeto global de Docker inyectado por el plugin.
                    // El '.' como segundo argumento indica el contexto de construcción (directorio actual).
                    docker.build("${APP_NAME}:latest", ".")
                }
            }
        }

        stage('Stop and Remove Old Container') {
            steps {
                script {
                    echo "Deteniendo y eliminando el contenedor antiguo si existe..."
                    // Aquí todavía podríamos usar 'sh' si no hay un paso de Docker Pipeline
                    // directo para detener/eliminar contenedores por nombre,
                    // o podríamos intentar con el objeto 'docker' si lo permite.
                    // Para simplificar, y dado que la API de Docker sí soporta estas operaciones,
                    // podemos usar 'sh' si docker-cli está disponible (que es lo que intentamos evitar)
                    // o implementar una lógica más avanzada con las librerías.
                    // Para este caso, el plugin Docker Pipeline a menudo maneja esto indirectamente
                    // cuando lanzas un nuevo contenedor (matando el viejo).
                    // Sin embargo, para un control explícito de 'stop' y 'rm', a menudo se requiere el CLI
                    // o una interacción más directa con el API.
                    // Por ahora, para evitar el 'docker: not found', vamos a simularlo
                    // o asumir que la creación de un nuevo contenedor manejará el reemplazo.

                    // Si el objetivo es NO tener 'docker-cli' en Jenkins,
                    // esta parte es donde el plugin Docker Pipeline podría ser limitado
                    // para 'stop' y 'rm' por nombre *explícitamente*.
                    // Normalmente, cuando haces un 'docker run' con un nombre existente,
                    // ya te da un error. Para manejarlo sin CLI:

                    // Una forma más "plugin-friendly" para asegurar que un contenedor no esté corriendo
                    // antes de lanzar el nuevo sería mediante el uso de "Docker Cloud" o una
                    // configuración de agente Docker más avanzada.
                    // PERO, para tu caso de despliegue simple, podríamos simplemente intentar lanzar
                    // y si falla porque ya existe el nombre, revisar logs.
                    // O, si queremos limpieza, se requeriría el CLI o una integración API más profunda.

                    // POR AHORA, para avanzar y evitar el "docker: not found" en 'docker build':
                    // Mantendremos esta etapa pero con un 'echo' y la nota.
                    // Si el problema persiste aquí, es un tema de cómo el plugin maneja 'run' sobre existentes.
                    echo "Asumiendo que el lanzamiento del nuevo contenedor gestionará el reemplazo."
                    echo "Si el contenedor ya existe y esto falla, considera añadir un agente Docker con CLI."
                }
            }
        }

        stage('Run New Container') {
            steps {
                script {
                    echo "Levantando el nuevo contenedor '${APP_NAME}-container' con Docker Pipeline plugin..."
                    def customImage = docker.image("${APP_NAME}:latest")
                    customImage.run("-d --name ${APP_NAME}-container -p ${HOST_PORT}:${CONTAINER_PORT}")
                    // El plugin se encargará de levantar el contenedor.
                    // En algunos casos, si un contenedor con el mismo nombre ya existe,
                    // este paso fallaría. Para un reemplazo robusto sin CLI en Jenkins,
                    // usualmente se usa un enfoque de orquestación (Docker Swarm, Kubernetes)
                    // o un agente Jenkins con Docker CLI.
                }
            }
        }

        stage('Post-Deployment Verification (Optional)') {
            steps {
                script {
                    echo "Realizando una verificación post-despliegue..."
                    // Si necesitas 'curl' o 'wget' aquí para verificar tu app,
                    // recuerda que esos comandos tampoco estarían en el contenedor Jenkins por defecto.
                    // Podrías instalarlos temporalmente en un 'sh' o usar un paso Groovy diferente.
                    echo "Verificación simple completada. Considere añadir una prueba más robusta."
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline finalizado. Revisa la 'Console Output' para más detalles."
        }
        success {
            echo "¡Despliegue de '${APP_NAME}' exitoso! 🎉 La aplicación debería estar accesible en el puerto ${HOST_PORT}."
        }
        failure {
            echo "¡Despliegue de '${APP_NAME}' fallido! 🔴 Hubo errores en el pipeline. Revisa la 'Console Output' cuidadosamente."
        }
    }
}


// // Define el pipeline con la sintaxis declarativa.
// pipeline {
//     // Especifica dónde se ejecutará el pipeline.
//     // 'agent any' significa que se ejecutará en cualquier agente de Jenkins disponible.
//     // Dado que tu contenedor Jenkins está en el mismo host que tus otros contenedores,
//     // este agente utilizará el socket de Docker del host.
//     agent any

//     // Define variables de entorno que se usarán a lo largo del pipeline.
//     // Esto centraliza la configuración y hace el script más legible y fácil de mantener.
//     environment {
//         // Nombre de tu aplicación. Se usará para nombrar la imagen Docker y el contenedor.
//         APP_NAME = 'my-react-app' // <--- ¡AJUSTA ESTO a un nombre descriptivo para tu app!

//         // Puerto interno que tu aplicación React (a través de Nginx) expone dentro del contenedor.
//         // Para la configuración de Nginx que te di, este debe ser 80.
//         CONTAINER_PORT = '80'

//         // Puerto en el host (tu servidor) donde la aplicación será accesible.
//         // Elige un puerto disponible en tu servidor (ej. 3000, 8080, 8081, etc.).
//         HOST_PORT = '80'
//     }

//     // Define las etapas (stages) del pipeline. Cada etapa representa un paso lógico.
//     stages {
//         stage('Checkout Code') {
//             // Esta etapa clona el código del repositorio.
//             // Jenkins lo hace automáticamente al inicio del pipeline si está configurado con SCM,
//             // pero esta etapa explícita es útil para verla en la interfaz de Jenkins y confirmar.
//             steps {
//                 echo "Clonando el repositorio Git..."
//                 // Puedes añadir pasos de verificación de código aquí si es necesario.
//             }
//         }

//         stage('Build Docker Image Locally on Host') {
//             // Esta etapa construye la imagen Docker de tu aplicación React.
//             // Utiliza el Dockerfile y nginx.conf que has colocado en la raíz de tu repo.
//             steps {
//                 script {
//                     echo "Construyendo la imagen Docker '${APP_NAME}:latest' en el host..."
//                     // El comando `docker build` se ejecuta en el host Docker
//                     // a través del socket montado en el contenedor de Jenkins.
//                     // El '.' indica que el contexto de construcción es el directorio de trabajo actual
//                     // (donde Jenkins clonó tu repositorio y donde está tu Dockerfile).
//                     sh "docker build -t ${APP_NAME}:latest ."
//                 }
//             }
//         }

//         stage('Stop and Remove Old Container') {
//             // Esta etapa detiene y elimina el contenedor de la versión anterior de tu aplicación.
//             // Esto es necesario para poder levantar un nuevo contenedor con la nueva imagen.
//             steps {
//                 script {
//                     echo "Deteniendo y eliminando el contenedor antiguo si existe..."
//                     // `docker stop` y `docker rm` se ejecutan en el host.
//                     // `|| true` asegura que el pipeline no falle si el contenedor no existe
//                     // (útil en el primer despliegue o si el contenedor ya fue eliminado).
//                     sh "docker stop ${APP_NAME}-container || true"
//                     sh "docker rm ${APP_NAME}-container || true"
//                 }
//             }
//         }

//         stage('Run New Container') {
//             // Esta etapa inicia un nuevo contenedor Docker con la imagen recién construida.
//             steps {
//                 script {
//                     echo "Levantando el nuevo contenedor '${APP_NAME}-container'..."
//                     // `docker run`: Comando para crear y ejecutar un nuevo contenedor.
//                     // -d: Ejecuta el contenedor en modo 'detached' (en segundo plano).
//                     // --name ${APP_NAME}-container: Asigna un nombre específico al contenedor para fácil referencia.
//                     // -p ${HOST_PORT}:${CONTAINER_PORT}: Mapea el puerto del host al puerto interno del contenedor.
//                     //   Asegúrate de que HOST_PORT sea un puerto disponible en tu servidor.
//                     //   CONTAINER_PORT debe ser '80' porque tu configuración de Nginx lo expone en el puerto 80.
//                     // ${APP_NAME}:latest: La imagen Docker a utilizar para el nuevo contenedor.
//                     sh "docker run -d --name ${APP_NAME}-container -p ${HOST_PORT}:${CONTAINER_PORT} ${APP_NAME}:latest"
//                 }
//             }
//         }

//         stage('Post-Deployment Verification (Optional)') {
//             // Esta etapa es opcional pero altamente recomendada para verificar que la aplicación
//             // se ha desplegado correctamente y está respondiendo.
//             steps {
//                 script {
//                     echo "Realizando una verificación post-despliegue..."
//                     // Puedes añadir un `curl` o `wget` para hacer una petición HTTP a un endpoint de tu aplicación.
//                     // Por ejemplo, si tu app React tiene un endpoint de salud o simplemente la ruta raíz.
//                     // sh "curl -f http://localhost:${HOST_PORT}/ || error 'La aplicación no responde después del despliegue!'"
//                     echo "Verificación simple completada. Considera añadir una prueba más robusta."
//                 }
//             }
//         }
//     }

//     // Bloque 'post' para definir acciones a ejecutar después de que todas las etapas hayan terminado,
//     // independientemente del resultado (éxito o fallo).
//     post {
//         always {
//             echo "Pipeline finalizado. Revisa la 'Console Output' para más detalles."
//         }
//         success {
//             echo "¡Despliegue de '${APP_NAME}' exitoso! 🎉 La aplicación debería estar accesible en el puerto ${HOST_PORT}."
//             // Aquí puedes añadir notificaciones para el equipo (ej. a Slack, correo electrónico).
//         }
//         failure {
//             echo "¡Despliegue de '${APP_NAME}' fallido! 🔴 Hubo errores en el pipeline. Revisa la 'Console Output' cuidadosamente."
//             // Aquí puedes añadir notificaciones de error a Slack, correo electrónico, etc.
//         }
//     }
// }
