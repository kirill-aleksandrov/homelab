openssl genpkey -genparam -algorithm EC -pkeyopt ec_paramgen_curve:secp384r1 -out EC-PARAMS.pem
openssl genpkey -paramfile EC-PARAMS.pem -out EC-KEY.pem
openssl req -x509 -sha512 -days 3650 -key EC-KEY.pem -out ROOT-CA.pem -config ca.conf -new -nodes
