#!/bin/bash

#hostname='htolsad01'
hostname='pkolsa01'

case $(echo $hostname|cut -c 1,2) in
  pc)
  DOMAIN=common
  ;;
  ht)
  DOMAIN=hotel
  ;;
  pk)
  DOMAIN=package
  ;;
  ar)
  DOMAIN=air
  ;;
  st)
  DOMAIN=account
  ;;
esac

case $(echo $hostname|cut -c 3,4,5) in
  ols)
  SERVICE=ols
  ;;
  api)
  SERVICE=api
  ;;
  btc)
  SERVICE=bat
  ;;
  apa)
  SERVICE=apa
esac

case $(echo $hostname|cut -c 7) in [0-9])
    TYPE=prd
  ;;
  d)
    TYPE=dev
  ;;
  s)
    TYPE=stg
  ;;
  *)
    echo "# TYPE: unknown"
  ;;
esac

echo "### information ###"
echo -e "# DOMAIN = $DOMAIN "
echo -e "# SERVICE = $SERVICE "
echo -e "# TYPE = $TYPE \\n"
