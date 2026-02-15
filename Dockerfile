# ---------- Stage 1: Use Official Nginx Image ----------
FROM nginx:alpine

# ---------- Remove Default Nginx Website ----------
RUN rm -rf /usr/share/nginx/html/*

# ---------- Copy Our Application ----------
COPY index.html /usr/share/nginx/html/

# ---------- Expose Port ----------
EXPOSE 80

# ---------- Start Nginx ----------
CMD ["nginx", "-g", "daemon off;"]
