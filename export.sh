#!/bin/bash

# -- DEFINICIÓN VARIABLES DE FECHA Y HORA.
DIA=`date +"%Y%m%d"`
HORA=`date +"%H%M"`

# -- CONFIGURACIÓN DE VARIABLES GLOBALES
DUMP_HOME="."
DUMP_FILE="dump_"$DIA"_"$HORA".sql"

MYSQL_DBUSER_ADM='root'
MYSQL_DBNAME="new_web_leenhcraft"
PG_DBUSER_ADM=""
PG_DBNAME=""

# -- SE LIMPIA LA CONSOLA Y SE DESPLIEGA EL TITULO DEL PROGRAMA.
clear
echo "EXPORT"
echo "======"

# -- SE VERIFICA QUE EL USUARIO HAYA PASADO COMO PARAMETRO DE LA APLICACIÓN EL TIPO
# DE BASE DE DATOS A LA QUE SE TIENE QUE CONECTAR EL SISTEMA (MYSQL O POSTGRESQL)
if [ -z $1 ]; then
    echo "Error en la ejecución! Faltan parámetros.."
    echo "Ejemplo ejecución:"
    echo
    echo "  $ sh export.sh [mysql|pg]"
    echo
    exit
fi
#
# -- SE COMPRUEBA QUE EL PRIMER PARÁMETRO RECIBIDO CORRESPONDA 
# A LAS OPCIONES VÁLIDAS QUE SON mysql Y pg.
if [ $1 != "mysql" ] && [ $1 != "pg" ]; then
    echo "Error en la ejecución! las opciones para el primer parámetro pueden ser solamente 'mysql' y 'pg' (postgres)."
    echo "Ejemplo ejecución:"
    echo
    echo "  $ sh export.sh [mysql|pg]"
    echo
    exit
fi
# -- SE LE SOLICITA AL OPERADOR QUE INGRESE LA CONTRASEÑA DEL USUARIO
# ADMINISTRADOR DE LA BASE DE DATOS.
STTY_SAVE=$(stty -g)
stty -echo
if [ $1 == "mysql" ]; then
    echo "Favor de introducir a continuación la contraseña del usuario '$MYSQL_DBUSER_ADM', administrador del motor de base de datos 'MySQL'."
elif [ $1 == "pg" ]; then
    echo "Favor de introducir a continuación la contraseña del usuario '$PG_DBUSER_ADM', administrador del motor de base de datos 'PostgreSQL'."
else
    echo "Favor de introducir a continuación la contraseña del usuario administrador del motor de base de datos."
fi
echo
echo -n "Introduzca Password:"
read DBADMIN_SECRET_PASSWD
stty $STTY_SAVE
echo
echo
# -- SEGÚN LA BASE DE DATOS ESPECIFICADA SE PROCEDE A EXPORTAR LA BASE DE DATOS.
if [ $1 == "mysql" ]; then
    echo "Exportando la base de datos MySQL '$MYSQL_DBNAME' del sistema. Aguarde un momento..."
    mysqldump -v -u $MYSQL_DBUSER_ADM -p $DBADMIN_SECRET_PASSWD $MYSQL_DBNAME > $DUMP_HOME/mysql-$DUMP_FILE
    echo "Fin del proceso de exportación! El archivo de exportación generado se encuentra en '$DUMP_HOME/mysql-$DUMP_FILE'."
    echo
elif [ $1 == "pg" ]; then
    echo "Exportando la base de datos PostgreSQL '$PG_DBNAME' del sistema. Aguarde un momento..."
    export PGUSER=$PG_DBUSER_ADM
    export PGPASSWORD=$DBADMIN_SECRET_PASSWD
    pg_dump -b -F p --column-inserts $PG_DBNAME > $DUMP_HOME/pg-$DUMP_FILE
    unset PGUSER
    unset PGPASSWORD
    echo "Fin del proceso de exportación! El archivo de exportación generado se encuentra en '$DUMP_HOME/pg-$DUMP_FILE'."
else
    echo "Opción no soportada!"
    echo
fi