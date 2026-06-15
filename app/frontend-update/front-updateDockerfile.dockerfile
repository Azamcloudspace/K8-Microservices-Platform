FROM public.ecr.aws/nginx/nginx:latest
COPY app/frontend-update/front-update.html /usr/share/nginx/html/index.html
EXPOSE 80
