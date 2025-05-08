My first attempt to provision kubernetes providers and operators

To run helmfile with .env file use `set -a; source .env; set +a;`. Example:
```
set -a; source .env; set +a; helmfile apply
```
