# bind9 on Alpine

Ansible playbook to install bind9 in on alpine

Alpine comes with `doas` instead of `sudo`

```
ansible-playbook -i $INVENTORY --become --become-method=doas ./playbook.yml
```
