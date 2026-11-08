# Utilidad de administración

La utilidad `wazuh_reset_password.sh` genera y aplica una contraseña para un usuario interno del Wazuh Indexer mediante `wazuh-passwords-tool.sh`.

## Alcance

- Instalación Wazuh All-in-One realizada con paquetes.
- Ejecución en el servidor que aloja Wazuh Indexer.
- Privilegios de `root`.
- No cubre Docker, Kubernetes ni despliegues distribuidos.

En un despliegue distribuido, sigue la [guía oficial de gestión de contraseñas](https://documentation.wazuh.com/current/user-manual/user-administration/password-management.html), porque las credenciales deben sincronizarse entre varios nodos.

## Obtener la utilidad

Desde una copia clonada del repositorio:

```bash
git clone https://github.com/AngelmzDev/Wazuh-SOC-lab.git
cd Wazuh-SOC-lab
chmod 750 wazuh_reset_password.sh
```

También puedes descargar solo el archivo:

```bash
curl -fLO https://raw.githubusercontent.com/AngelmzDev/Wazuh-SOC-lab/main/wazuh_reset_password.sh
chmod 750 wazuh_reset_password.sh
```

Revisa el archivo antes de ejecutarlo.

## Diagnóstico sin cambios

```bash
sudo ./wazuh_reset_password.sh --check
```

Comprueba la presencia de la herramienta oficial y el estado de `wazuh-indexer`, `filebeat`, `wazuh-manager` y `wazuh-dashboard`. No cambia contraseñas ni reinicia servicios.

## Generar una contraseña

```bash
sudo ./wazuh_reset_password.sh --generate
```

Wazuh genera una contraseña aleatoria para `admin` y la muestra una vez en la terminal. Guárdala inmediatamente en un gestor de secretos. Evita capturar la salida en historiales, tickets o registros compartidos.

Para otro usuario interno:

```bash
sudo ./wazuh_reset_password.sh --generate --user readall
```

Para reiniciar y comprobar los componentes que dependen de las credenciales:

```bash
sudo ./wazuh_reset_password.sh --generate --restart
```

El reinicio causa una interrupción breve del laboratorio. La utilidad reinicia Filebeat, Wazuh Manager y Wazuh Dashboard; no reinicia el Indexer para un cambio que la herramienta oficial aplica en línea.

## Contraseña elegida manualmente

La utilidad genera contraseñas para evitar que una contraseña escrita quede en el historial del shell. Si necesitas una contraseña concreta, usa directamente la herramienta oficial y sigue sus requisitos:

```bash
sudo bash /usr/share/wazuh-indexer/plugins/opensearch-security/tools/wazuh-passwords-tool.sh \
  --user admin \
  --password 'Sustituye-Este-Ejemplo-42'
```

El argumento puede ser visible temporalmente en la lista de procesos y quedar en el historial. Borra esa entrada del historial o utiliza el procedimiento de gestión de secretos de tu organización.

## Después del cambio

1. Cierra sesiones antiguas del Dashboard.
2. Comprueba el inicio de sesión con la nueva contraseña.
3. Ejecuta `sudo ./wazuh_reset_password.sh --check`.
4. Revisa los registros si algún servicio no está activo:

```bash
sudo journalctl -u wazuh-dashboard -u wazuh-manager -u filebeat --since "-10 min"
```

La utilidad termina con error si falta la herramienta oficial, una opción es inválida o un servicio reiniciado no vuelve al estado activo.
