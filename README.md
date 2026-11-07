<p align="center">
  <img src="docs/branding/logo.svg" alt="Logo de Wazuh-SOC-lab" width="128" height="128">
</p>

# 🛡️ Proyecto: Wazuh SOC Lab (All-in-One)

## 👤 Implementado por: zerozeid

Este repositorio documenta el proceso paso a paso para la instalación de una plataforma de Seguridad (SIEM/XDR) utilizando Wazuh All-in-One sobre Ubuntu Server.

---

## 🧱 1. Requisitos del Sistema Base

Esta configuración está diseñada para una instalación Wazuh All-in-One (Manager, Indexer, Dashboard) en un único servidor, optimizada para un entorno de laboratorio (Lab) o Prueba de Concepto (POC).

* **CPU:** 4+ núcleos (Mínimo: 2 núcleos).
* **RAM:** 16 GB (Mínimo: 8 GB).
* **Almacenamiento:** Recomendable un SSD para el buen rendimiento del Indexer (OpenSearch). 
* **Sistema Operativo:** Ubuntu Server 22.04 LTS (o superior).
* **Usuario Principal:** `Tu nombre de usuario` (configurado como usuario administrador).
* **Networking:** Configuración de red cableada.

## ⚙️ 2. Configuración Inicial de Ubuntu

Las siguientes decisiones se tomaron durante la instalación inicial del sistema operativo:

* **Tipo de Instalación:** Mínima (Minimized) para ahorrar recursos del sistema.
* **Servicios Incluidos:** Se habilitó el **OpenSSH Server** para la administración remota.
* **Activación:** Se adjuntó la cuenta de Ubuntu Pro (opcional pero recomendado).

### 2.1 💾 Particionamiento del Disco (SSD 240 GB)

Se utilizó un esquema de particionamiento manual para priorizar el espacio para los datos de Wazuh/OpenSearch en el SSD.

* **`/boot`:** 1 GB (Para los archivos de arranque).
* **`swap`:** 8 GB (Memoria de Intercambio, esencial para el rendimiento del Indexer/OpenSearch).
* **`/` (Root):** **Todo el espacio restante (~231 GB).** Este es el punto de montaje clave donde se almacenarán todos los logs de seguridad.

> **Decisión clave:** Asignar casi todo el espacio del SSD al directorio Root (`/`) para maximizar la capacidad de almacenamiento de logs de Wazuh.

> **Nota:** Se seleccionó el SSD Kingston de 240 GB como destino de la instalación.

## 🚀 3. Comandos de Instalación de Wazuh (All-in-One)

Una vez estés dentro de la terminal estos serán los pasos a seguir para instalar Wazuh (All-in-One)

1.  🛠️**Preparación del sistema:**
    ```bash
    sudo apt update && sudo apt upgrade -y   #Actualiza y upgradea el sistema
    sudo apt install curl wget -y            # Instala Curl
    ```
    
2.  **Descarga y ejecución del script de instalación:**
3.  
  # Descarga el instalador de Wazuh. NOTA: -sO usa la O mayúscula.
      `curl -sO https://packages.wazuh.com/4.14/wazuh-install.sh`

# Damos privilegios de ejecución al script
      `chmod +x wazuh-install.sh`

# Ejecutamos el script con permisos de administrador para la instalación All-in-One (-a)

# NOTA: Este proceso puede tardar entre 20 y 40 minutos.
sudo ./wazuh-install.sh -a
 3. **🧹Elimina los paquetes que se instalaron como dependencia y ya no se utilizan y reinicia el sistema**

  ```
  sudo apt autoremove     #Elimina los paquetes que se instalaron como dependencia y ya no se utilizan
  sudo reboot now         # Reinicia el sistema para asegurar que todos los servicios carguen correctamente

  ```
    
    *Nota: El script instala Wazuh Manager, OpenSearch Indexer y OpenSearch Dashboard.*

## 🛠️ Utilidades de Administración

Actualmente, el repositorio incluye scripts de administración esenciales:

* **`wazuh_reset_password.sh`**: Script para automatizar el restablecimiento de la contraseña del usuario `admin` del Wazuh Dashboard.

### 📖 Cómo usar el script

Para instrucciones detalladas sobre la instalación, requisitos y ejecución del script `wazuh_reset_password.sh`, haz clic en el siguiente enlace:

[**Ver el Modo de Uso Detallado aquí**](./USAGE.md)
