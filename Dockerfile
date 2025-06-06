# Stage 1: Build the React application
# Utiliza una imagen Node.js ligera para la etapa de construcción.
# Recomendamos una versión LTS de Alpine para imágenes más pequeñas.
FROM node:20-alpine AS build-stage

# Establece el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Copia los archivos package.json y yarn.lock primero.
# Esto permite que Docker cachee la capa de instalación de dependencias
# si estos archivos no cambian, acelerando futuras construcciones.
COPY package.json yarn.lock ./

# Instala las dependencias del proyecto usando Yarn.
RUN yarn install --frozen-lockfile

# Copia el resto del código de la aplicación.
COPY . .

# Compila la aplicación React para producción.
# Esto generará los archivos estáticos en el directorio 'build' (por defecto).
# Si tu script de build es diferente (ej. 'yarn build:prod'), ajusta el comando.
RUN yarn build

# Stage 2: Serve the React application with Nginx
# Utiliza una imagen Nginx muy ligera para servir los archivos estáticos.
FROM nginx:alpine AS production-stage

# Copia la configuración personalizada de Nginx.
# Asegúrate de tener el archivo 'nginx.conf' en la misma carpeta que tu Dockerfile.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia los archivos estáticos compilados desde la etapa de construcción
# al directorio de Nginx donde se servirán.
# El directorio 'build' es el output por defecto de 'create-react-app'.
# Si tu aplicación usa otro directorio de salida (ej. 'dist'), ajusta esto.
COPY --from=build-stage /app/build /usr/share/nginx/html

# Expone el puerto 80, que es el puerto predeterminado de Nginx.
EXPOSE 80

# Comando para iniciar Nginx en primer plano cuando el contenedor se inicie.
CMD ["nginx", "-g", "daemon off;"]
