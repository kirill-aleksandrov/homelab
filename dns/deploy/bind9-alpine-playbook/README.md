# bind9 on Alpine

Ansible playbook to install bind9 in on alpine

```
ansible-playbook -i $INVENTORY ./playbook.yml
```

The generated TSIG is stored in `/etc/bind/{{ zone }}-tsig.conf.key`
