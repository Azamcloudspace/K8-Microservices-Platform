FROM public.ecr.aws/nginx/nginx:latest
COPY app/frontend/index.html /usr/share/nginx/html/index.html
EXPOSE 80
