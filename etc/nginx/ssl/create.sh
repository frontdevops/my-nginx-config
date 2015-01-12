#!/bin/bash

openssl genrsa -rand file1:file2:file3 -out server.key

openssl req -new -key server.key -out server.csr \
		-subj /C=RU/ST=Moscow/L=Moscow/O=IZEROZ/OU=I0Z/CN=i0z.ru/emailAddress=support@i0z.ru \

openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

exit

# req Запрос на создание нового сертификата.
# -new Создание запроса на сертификат (Certificate Signing Request – далее CSR).
# -newkey rsa:1023 Автоматически будет создан новый закрытый RSA ключ длиной 1024 бита. Длину ключа можете настроить по своему усмотрению.
# -nodes Не шифровать закрытый ключ.
# -keyout ca.key Закрытый ключ сохранить в файл ca.key.
# -x509 Вместо создания CSR (см. опцию -new) создать самоподписанный сертификат.
# -days 500 Срок действия сертификата 500 дней. Размер периода действия можете настроить по своему усмотрению. Не рекомендуется вводить маленькие значения, так как этим сертификатом вы будете подписывать клиентские сертификаты.
# -subj /C=RU/ST=Moscow/L=Moscow/O=Companyname/OU=User/CN=etc/emailAddress=support@site.com
# Данные сертификата, пары параметр=значение, перечисляются через ‘/’. Символы в значении параметра могут быть «подсечены» с помощью обратного слэша «\», например «O=My\ Inc». Также можно взять значение аргумента в кавычки, например, -subj «/xx/xx/xx».

openssl req -new -newkey rsa:1024 -nodes \
	-keyout ca.key -x509 -days 730 \
	-subj /C=RU/ST=Moscow/L=Moscow/O=Miuapps/OU=Miuapps.com/CN=Majorsoft/emailAddress=support@miuapps.com \
	-out ca.crt

# Создадим сертификат для nginx и запрос для него
openssl genrsa -des3 -out server.key 1024
openssl req -new -key server.key -out server.csr

# Подпишем сертификат нашей же собственной подписью
openssl x509 -req -days 365 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt

# Чтобы nginx при перезагрузке не спрашивал пароль, сделаем для него беспарольную копию сертификата
openssl rsa -in server.key -out server.nopass.key

openssl req -new -newkey rsa:1024 -nodes -keyout client01.key \
		-subj /C=RU/ST=Moscow/L=Moscow/O=Miuapps/OU=Miuapps.com/CN=Majorsoft/emailAddress=support@miuapps.com \
		-out client01.csr

openssl ca -config ca.config -in client01.csr -out client01.crt -batch

openssl pkcs12 -export -in client01.crt -inkey client01.key -certfile ca.crt -out client01.p12 -passout pass:Major658

#EOF