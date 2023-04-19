FROM mysql
ENV MYSQL_ROOT_PASSWORD=password
ENV MYSQL_DATABASE=magento
ENV MYSQL_USER=magento
ENV MYSQL_PASSWORD=magento
COPY magento_magento2.sql.gz /docker-entrypoint-initdb.d
