FROM mysql:5.7

RUN echo "sql_mode=NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION"\
 >> /etc/mysql/mysql.conf.d/mysqld.cnf
