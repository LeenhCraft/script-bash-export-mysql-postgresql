#!/bin/bash

if ! command -v gunzip > /dev/null; then
	echo "gzip no se encuentra, no se comprime"
fi

if ! command -v mysqldump > /dev/null; then
	echo "mysqldump no se encuentra, abortando"
	exit 1
fi

# IMPORT
ARCHIVO_DB='ale.sql'
USUARIO_DB='root'
NOMBRE_DB='demo'
HOST=''

if [ -z $NOMBRE_DB ] || [ -z $ARCHIVO_DB ] || [ -z $USUARIO_DB ]; then
	echo "Faltan parámetros, abortando."
	exit 1
fi

if [ ! -f "$ARCHIVO_DB" ]; then
	echo "Archivo $ARCHIVO_DB no encontrado, abortando."
	exit 1
fi

if [ "$USUARIO_DB" != "root" ]; then
	USUARIO_COMMAND="-u$USUARIO_DB -p"
else
	if [ -f /root/.my.cnf ]; then
		echo "Exportando utilizando credenciales de /root/.my.cnf"
	else
		USUARIO_COMMAND="-u$USUARIO_DB -p"
	fi
fi

if [ ! -z $HOST ]; then
	HOST="-h $HOST"
fi

if [ "$USUARIO_DB" != "root" ]; then
	echo -n "MySQL " # PARA QUE SE ACOPLE AL PEDIDO DE PASSWORD DEL COMANDO MYSQLDUMP
fi

if command -v gunzip > /dev/null && (echo "$ARCHIVO_DB" | grep ".gz$" > /dev/null); then
	gunzip < "$ARCHIVO_DB" | sed -E 's/DEFINER=`[^`]+`@`[^`]+`/DEFINER=CURRENT_USER/g' | mysql $USUARIO_COMMAND $HOST $NOMBRE_DB && echo "Base de datos $ARCHIVO_DB importada en $NOMBRE_DB"
else
	cat "$ARCHIVO_DB" | sed -E 's/DEFINER=`[^`]+`@`[^`]+`/DEFINER=CURRENT_USER/g' | mysql $USUARIO_COMMAND $HOST $NOMBRE_DB && echo "Base de datos $ARCHIVO_DB importada en $NOMBRE_DB"
fi