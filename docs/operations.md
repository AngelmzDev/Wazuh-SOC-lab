# Operación y mantenimiento

## Comprobación diaria

```bash
sudo systemctl is-active wazuh-indexer wazuh-manager wazuh-dashboard filebeat
df -h
free -h
sudo journalctl --disk-usage
```

Comprueba también en el Dashboard que los agentes estén activos, que entren alertas recientes y que la cola o la latencia no crezcan.

## Diagnóstico de servicios

```bash
sudo systemctl --no-pager --full status wazuh-indexer
sudo systemctl --no-pager --full status wazuh-manager
sudo systemctl --no-pager --full status wazuh-dashboard
sudo systemctl --no-pager --full status filebeat
```

Para revisar los últimos diez minutos:

```bash
sudo journalctl -u wazuh-indexer -u wazuh-manager \
  -u wazuh-dashboard -u filebeat --since "-10 min"
```

## Puertos y exposición

```bash
sudo ss -lntp
sudo ufw status numbered
```

1514/TCP y 1515/TCP deben aceptar únicamente redes de agentes; 443/TCP, la red administrativa. Mantén 9200/TCP y 55000/TCP fuera de Internet.

## Contraseñas

Antes de cambiar credenciales:

1. crea un snapshot de la VM;
2. confirma que los cuatro servicios están activos;
3. abre una ventana de mantenimiento;
4. conserva acceso SSH alternativo;
5. ejecuta el diagnóstico de [la utilidad](../USAGE.md).

La herramienta oficial actualiza las dependencias necesarias de una instalación All-in-One. Un despliegue distribuido requiere pasos adicionales en cada componente.

## Copias y restauración

Un snapshot de VM es útil para el laboratorio, pero no sustituye una copia consistente del Indexer. Para datos importantes:

- configura snapshots del Wazuh Indexer en un repositorio separado;
- conserva `/var/ossec/etc/`, reglas, decodificadores y configuración de Filebeat;
- guarda certificados y secretos en almacenamiento cifrado;
- documenta versiones y prueba la restauración.

Una copia que nunca se ha restaurado es una hipótesis, no una recuperación validada.

## Actualizaciones

No habilites el repositorio y ejecutes una actualización general sin revisar antes la guía de actualización de Wazuh. Procedimiento mínimo:

1. consulta compatibilidad y cambios de la versión objetivo;
2. crea copias y snapshot;
3. prueba en una clonación del laboratorio;
4. programa mantenimiento;
5. habilita temporalmente el repositorio;
6. actualiza siguiendo el orden oficial;
7. verifica servicios, agentes, alertas y búsquedas;
8. vuelve a deshabilitar el repositorio.

Registra fecha, versión anterior, versión nueva, resultado y ruta de vuelta atrás.

## Primera prueba funcional

Después de enrolar un agente:

1. confirma que figura como activo;
2. genera un evento controlado y no dañino, como varios intentos SSH fallidos con una cuenta de laboratorio;
3. localiza la alerta en el Dashboard;
4. anota agente, regla, nivel y hora;
5. elimina cualquier cuenta o configuración temporal.

No ejecutes malware ni técnicas destructivas para demostrar que el laboratorio recibe eventos.
