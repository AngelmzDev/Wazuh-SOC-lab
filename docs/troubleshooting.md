# Resolución de problemas

## El Dashboard no abre

```bash
sudo systemctl status wazuh-dashboard --no-pager
sudo journalctl -u wazuh-dashboard --since "-15 min"
sudo ss -lntp | grep ':443'
curl -kI https://127.0.0.1/
```

Si funciona localmente pero no desde otro equipo, revisa UFW, la red de la VM y la ruta entre cliente y servidor.

## El Dashboard abre pero no muestra datos

```bash
sudo systemctl is-active wazuh-manager wazuh-indexer filebeat
sudo journalctl -u filebeat --since "-15 min"
sudo journalctl -u wazuh-indexer --since "-15 min"
```

Comprueba espacio libre. Un disco lleno puede impedir la indexación.

## Un agente no conecta

Desde el agente, prueba los puertos del Manager:

```bash
nc -zv DIRECCION_DEL_MANAGER 1514 1515
```

Confirma la dirección configurada, la hora del sistema, UFW y que el agente aparezca enrolado.

## Falló un cambio de contraseña

No edites `internal_users.yml` como primer intento. Ejecuta:

```bash
sudo ./wazuh_reset_password.sh --check
sudo journalctl -u wazuh-dashboard -u wazuh-manager -u filebeat --since "-15 min"
```

Si el despliegue no es All-in-One o se instaló con contenedores, utiliza el procedimiento oficial específico. No cargues todo el directorio de seguridad con `securityadmin.sh` sin una copia de la configuración activa: puede reemplazar usuarios, roles y otros recursos.

## Recopilar información para pedir ayuda

Comparte versiones, arquitectura, estado de servicios y mensajes relevantes. Oculta contraseñas, tokens, certificados privados, direcciones públicas y datos de agentes:

```bash
lsb_release -ds
uname -r
dpkg -l | grep -E 'wazuh|filebeat'
sudo systemctl is-active wazuh-indexer wazuh-manager wazuh-dashboard filebeat
```
