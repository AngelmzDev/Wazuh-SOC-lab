<p align="center">
  <img src="docs/branding/logo.svg" alt="Logo de Wazuh-SOC-lab" width="128" height="128">
</p>

# Wazuh SOC Lab en Ubuntu Server

Laboratorio reproducible para instalar y administrar Wazuh All-in-One sobre Ubuntu Server. Está pensado para aprendizaje, pruebas y pequeñas demostraciones; no describe una arquitectura de alta disponibilidad ni sustituye un diseño de producción.

## Contenido

1. [Instalación en Ubuntu Server](docs/installation.md)
2. [Operación, comprobaciones y mantenimiento](docs/operations.md)
3. [Uso de la utilidad administrativa](USAGE.md)
4. [Resolución de problemas](docs/troubleshooting.md)

## Arquitectura del laboratorio

Los componentes centrales comparten un servidor:

```text
Agentes --1514/TCP, 1515/TCP--> Wazuh Server
                                      |
                                   Filebeat
                                      |
                                      v
                                 Wazuh Indexer
                                      ^
                                      |
Administrador --443/TCP--> Wazuh Dashboard
```

Los puertos 9200 (Indexer API) y 55000 (Server API) deben permanecer limitados al propio servidor o a una red administrativa que realmente los necesite. No expongas el laboratorio directamente a Internet.

## Utilidad incluida

`wazuh_reset_password.sh` es un envoltorio conservador de `wazuh-passwords-tool.sh`, la herramienta oficial incluida con Wazuh Indexer. Puede:

- comprobar que la herramienta y los servicios All-in-One existen;
- generar una contraseña aleatoria para `admin` u otro usuario interno;
- reiniciar y verificar los servicios dependientes si se solicita expresamente.

No modifica `internal_users.yml` ni carga todo el directorio de seguridad mediante `securityadmin.sh`.

```bash
sudo ./wazuh_reset_password.sh --check
sudo ./wazuh_reset_password.sh --generate --restart
```

Lee [USAGE.md](USAGE.md) antes de utilizarla.

## Referencias

- [Quickstart oficial de Wazuh](https://documentation.wazuh.com/current/quickstart.html)
- [Arquitectura y puertos](https://documentation.wazuh.com/current/getting-started/architecture.html)
- [Gestión oficial de contraseñas](https://documentation.wazuh.com/current/user-manual/user-administration/password-management.html)

## Alcance y seguridad

Usa datos ficticios, una red aislada y snapshots de la máquina virtual. Las credenciales, archivos de instalación y copias de seguridad no deben publicarse en Git. Para producción se necesitan certificados de confianza, control de acceso, copias probadas, monitorización de capacidad y una arquitectura acorde al número de agentes y a la retención.
