FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy the app and logo
COPY index.html /usr/share/nginx/html/index.html
COPY logo/ /usr/share/nginx/html/logo/

# Expose port 8080
EXPOSE 8080

# Override nginx to listen on 8080
RUN sed -i 's/listen\s*80;/listen 8080;/g' /etc/nginx/conf.d/default.conf \
    && sed -i 's/listen\s*\[::\]:80/listen [::]:8080/g' /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]
