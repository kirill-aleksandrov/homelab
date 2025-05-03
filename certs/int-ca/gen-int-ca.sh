openssl genpkey \
    -genparam \
    -algorithm EC \
    -pkeyopt ec_paramgen_curve:secp384r1 \
    -out EC-PARAMS.pem
openssl genpkey \
    -paramfile EC-PARAMS.pem \
    -out EC-KEY.pem
openssl req \
    -new \
    -key "EC-KEY.pem" \
    -sha512 \
    -config "ca.conf" \
    -out INT-CA-CSR.pem
openssl x509 \
    -req \
    -sha512 \
    -days 3650 \
    -in INT-CA-CSR.pem \
    -out INT-CA.pem \
    -CA "../root-ca/ROOT-CA.pem" \
    -CAkey "../root-ca/EC-KEY.pem" \
    -copy_extensions copyall \
    -CAcreateserial
