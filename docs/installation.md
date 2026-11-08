# Instalación All-in-One en Ubuntu Server

## 1. Dimensionar el laboratorio

La guía rápida de Wazuh indica, como referencia para 1–25 agentes, 4 vCPU, 8 GiB de RAM y 50 GB de almacenamiento. Para un laboratorio con margen de retención:

| Recurso | Recomendación del laboratorio |
| --- | --- |
| CPU | 4 vCPU |
| RAM | 8 GB mínimo; 16 GB ofrece más margen |
| Disco | SSD de 100 GB o más; 240 GB permite mayor retención |
| Sistema | Ubuntu Server 22.04 o 24.04 LTS de 64 bits |

El consumo real depende de los agentes, eventos por segundo, módulos habilitados y días de retención. Mide el uso del Indexer en lugar de tratar estos valores como capacidad garantizada.

## 2. Preparar Ubuntu

Usa una dirección IP estable o una reserva DHCP, sincronización horaria y un nombre de host resoluble. Actualiza el sistema:

```bash
sudo apt update
sudo apt full-upgrade
sudo apt install --yes curl ca-certificates
sudo timedatectl set-ntp true
```

Para SSH, utiliza claves y limita el acceso a la red administrativa. Antes de desactivar la autenticación por contraseña, confirma una segunda sesión con la clave.

### Disco y memoria

Un volumen raíz amplio es suficiente para un laboratorio sencillo. En entornos donde importe la retención, separa `/var/lib/wazuh-indexer` para controlar el crecimiento sin llenar `/`.

La swap no mejora el rendimiento del Indexer. OpenSearch advierte que intercambiar memoria puede afectar gravemente al rendimiento y la estabilidad. En un laboratorio pequeño puede existir como protección frente a un agotamiento puntual, pero no debe compensar una RAM insuficiente; monitoriza `free -h`, la presión de memoria y el heap.

## 3. Restringir la red

Abre únicamente lo necesario y limita cada regla a su red de origen:

| Puerto | Origen recomendado | Uso |
| --- | --- | --- |
| 22/TCP | Red administrativa | SSH |
| 443/TCP | Red administrativa | Dashboard |
| 1514/TCP | Red de agentes | Eventos |
| 1515/TCP | Red de agentes | Enrolamiento |

Los puertos 9200/TCP y 55000/TCP son APIs internas. No los publiques en Internet. Si empleas UFW, sustituye los ejemplos por tus redes:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from 192.0.2.0/24 to any port 22 proto tcp
sudo ufw allow from 192.0.2.0/24 to any port 443 proto tcp
sudo ufw allow from 198.51.100.0/24 to any port 1514 proto tcp
sudo ufw allow from 198.51.100.0/24 to any port 1515 proto tcp
sudo ufw enable
sudo ufw status verbose
```

Las redes `192.0.2.0/24` y `198.51.100.0/24` son ejemplos de documentación: no las copies como configuración real.

## 4. Instalar Wazuh

Este repositorio se ha redactado para la rama 4.14. Comprueba la versión vigente en el Quickstart oficial antes de instalar:

```bash
curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh
sudo bash ./wazuh-install.sh -a
```

El asistente muestra la URL y las credenciales iniciales. El archivo `wazuh-install-files.tar` contiene material sensible:

```bash
sudo chmod 600 wazuh-install-files.tar
sudo tar -O -xvf wazuh-install-files.tar \
  wazuh-install-files/wazuh-passwords.txt
```

Tras guardar las credenciales en un gestor de secretos, mueve el archivo a una copia cifrada o elimínalo según tu política.

Wazuh recomienda deshabilitar su repositorio después de instalar para evitar actualizaciones accidentales:

```bash
sudo sed -i 's/^deb /#deb /' /etc/apt/sources.list.d/wazuh.list
sudo apt update
```

No ejecutes `apt autoremove` a ciegas después de la instalación. Revisa primero la lista propuesta.

## 5. Verificar

```bash
sudo systemctl is-active wazuh-indexer wazuh-manager wazuh-dashboard filebeat
sudo ss -lntp
curl -kI https://127.0.0.1/
```

Abre `https://IP_DEL_SERVIDOR/` desde la red administrativa. El certificado inicial puede generar una advertencia porque no procede de una autoridad de confianza. Para un entorno compartido o de producción, instala un certificado adecuado.

Continúa con [operación y mantenimiento](operations.md) y despliega el primer agente desde **Agents management > Summary > Deploy new agent**.
