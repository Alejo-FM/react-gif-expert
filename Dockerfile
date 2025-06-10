# Stage 1: Build the React application
# Utiliza una imagen Node.js ligera para la etapa de construcción.
# Recomendamos una versión LTS de Alpine para imágenes más pequeñas.
FROM node:18-alpine AS build-stage

ARG HTTP_PROXY
ARG HTTPS_PROXY

# Opcional: Si necesitas que el proxy se use durante la construcción,
# puedes configurar las variables de entorno para los comandos RUN
# que se ejecuten DESPUÉS de estas líneas.
ENV HTTP_PROXY=$HTTP_PROXY
ENV HTTPS_PROXY=$HTTPS_PROXY

# Establece el directorio de trabajo dentro del contenedor.
WORKDIR /app

# Copia el archivo package.json primero.
COPY package.json ./

# Instala las dependencias del proyecto usando npm.
RUN npm install

# Copia el resto del código de la aplicación.
COPY . .

# Compila la aplicación React para producción.
RUN npm run build

# Stage 2: Serve the React application with Nginx
# Utiliza una imagen Nginx muy ligera para servir los archivos estáticos.
FROM nginx:alpine AS production-stage

# Copia la configuración personalizada de Nginx.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copia los archivos estáticos compilados desde la etapa de construcción
COPY --from=build-stage /app/build /usr/share/nginx/html

# Expone el puerto 80, que es el puerto predeterminado de Nginx.
EXPOSE 80

# Comando para iniciar Nginx en primer plano cuando el contenedor se inicie.
CMD ["nginx", "-g", "daemon off;"]
