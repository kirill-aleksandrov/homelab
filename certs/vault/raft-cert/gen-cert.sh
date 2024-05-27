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
    -config "cert.conf" \
    -out VAULT-RAFT-CSR.pem
openssl x509 \
    -req \
    -sha512 \
    -days 3650 \
    -in VAULT-RAFT-CSR.pem \
    -out VAULT-RAFT.pem \
    -CA "../ca/VAULT-INT-CA.pem" \
    -CAkey "../ca/EC-KEY.pem" \
    -copy_extensions copyall \
    -CAcreateserial
