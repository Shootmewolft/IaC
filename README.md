
# Proyecto Terraform: Infraestructura como Código

Este proyecto utiliza **Terraform** para gestionar y aprovisionar infraestructura de forma automatizada. Se compone de tres archivos principales: `main.tf`, `variables.tf` y `output.tf`, donde se definen los recursos, las variables de configuración, y los outputs relevantes del despliegue. Esta configuración establece una infraestructura básica en AWS que incluye una VPC con subnets pública y privada, tablas de enrutamiento con acceso a Internet, una instancia EC2 con acceso SSH y tráfico HTTP/HTTPS permitido, y un NAT Gateway para tráfico saliente desde la subnet privada.

## Estructura del Proyecto

- **`main.tf`**: Define los recursos y proveedores de infraestructura.  
- **`variables.tf`**: Declara las variables usadas para parametrizar el despliegue.  
- **`output.tf`**: Define las salidas (outputs) importantes que se mostrarán al finalizar el despliegue.

---

## Requisitos

- **Terraform** >= 1.0  
- Proveedor cloud configurado (por ejemplo: AWS, Azure, GCP).  
- Acceso a credenciales válidas en tu entorno.  

---

## Instalación

1. **Clonar el repositorio**  
   ```bash
   git clone git@github.com:FCA-Cloud-Computing/shootCite-IaC.git
   cd shootCite--IaC
   ```

2. **Inicializar Terraform**  
   Ejecuta este comando para inicializar los proveedores necesarios:  
   ```bash
   terraform init
   ```

---

## Uso

1. **Planificar el despliegue**  
   Revisa los cambios que Terraform aplicará con:  
   ```bash
   terraform plan
   ```

2. **Aplicar la configuración**  
   Para desplegar los recursos, usa:  
   ```bash
   terraform apply
   ```

3. **Ver los outputs**  
   Una vez completado el despliegue, puedes revisar las salidas con:  
   ```bash
   terraform output
   ```

4. **Destruir la infraestructura**  
   Si necesitas eliminar todos los recursos:  
   ```bash
   terraform destroy
   ```

---

## Variables

Define tus variables en el archivo `variables.tf`. Aquí tienes un ejemplo de cómo pasar valores mediante la línea de comandos:  
```bash
terraform apply -var="nombre_variable=valor"
```

También puedes usar un archivo `terraform.tfvars` para definir las variables por defecto.

---

## Infraestructura en AWS con Terraform

### 1. Provider AWS

#### Configuración del Proveedor
- **Proveedor**: AWS
- **Región**: `us-east-1`

Configura la región predeterminada para todos los recursos de AWS en esta infraestructura.

---

### 2. VPC (Virtual Private Cloud)

#### Recurso: `aws_vpc.main`
- **CIDR Block**: `10.0.0.0/16`
- **Etiqueta**: `Name = "MainVPC"`

Crea una VPC con un rango de direcciones IP de `10.0.0.0/16`, permitiendo subnets privadas y públicas dentro de esta red.

---

### 3. Subnet Pública

#### Recurso: `aws_subnet.public_subnet`
- **VPC ID**: Referencia a `aws_vpc.main`
- **CIDR Block**: `10.0.1.0/24`
- **Etiqueta**: `Name = "PublicSubnet"`
- **Configuración**: Asignación de IPs públicas al iniciarse (`map_public_ip_on_launch = true`)

La subnet pública se usa para recursos que deben ser accesibles desde Internet, como instancias de EC2.

---

### 4. Subnet Privada

#### Recurso: `aws_subnet.private_subnet`
- **VPC ID**: Referencia a `aws_vpc.main`
- **CIDR Block**: `10.0.2.0/24`
- **Etiqueta**: `Name = "PrivateSubnet"`

Esta subnet alberga recursos no accesibles directamente desde Internet, utilizando un NAT Gateway para el tráfico saliente.

---

### 5. Tabla de Enrutamiento Pública

#### Recurso: `aws_route_table.public_rt`
- **VPC ID**: Referencia a `aws_vpc.main`
- **Etiqueta**: `Name = "public-route-table"`
- **Ruta**: `0.0.0.0/0` usando un Internet Gateway (`aws_internet_gateway.igw.id`)

Asocia esta tabla de enrutamiento a la subnet pública, permitiendo acceso a Internet.

#### Asociación: `aws_route_table_association.public_association`
- **Subnet ID**: `aws_subnet.public_subnet.id`
- **Route Table ID**: `aws_route_table.public_rt.id`

---

### 6. Tabla de Enrutamiento Privada

#### Recurso: `aws_route_table.private_rt`
- **VPC ID**: Referencia a `aws_vpc.main`
- **Etiqueta**: `Name = "private-route-table"`
- **Ruta**: `0.0.0.0/0` usando un NAT Gateway (`aws_nat_gateway.nat_gw.id`)

Asocia esta tabla de enrutamiento a la subnet privada, permitiendo que instancias privadas accedan a Internet de forma segura para el tráfico saliente.

#### Asociación: `aws_route_table_association.private_association`
- **Subnet ID**: `aws_subnet.private_subnet.id`
- **Route Table ID**: `aws_route_table.private_rt.id`

---

### 7. Internet Gateway

#### Recurso: `aws_internet_gateway.igw`
- **VPC ID**: Referencia a `aws_vpc.main`
- **Etiqueta**: `Name = "MainIGW"`

Proporciona acceso a Internet para la subnet pública.

---

### 8. NAT Gateway

#### Elastic IP: `aws_eip.nat_eip`

#### Recurso NAT Gateway: `aws_nat_gateway.nat_gw`
- **Allocation ID**: `aws_eip.nat_eip.id`
- **Subnet ID**: `aws_subnet.public_subnet.id`
- **Etiqueta**: `Name = "MainNAT"`

El NAT Gateway permite que las instancias en la subnet privada accedan a Internet de forma segura para el tráfico saliente.

---

### 9. Instancia EC2 (Servidor Web)

#### Recurso: `aws_instance.web_server`
- **AMI**: `ami-0866a3c8686eaeeba`
- **Tipo de Instancia**: `t2.micro`
- **Subnet ID**: `aws_subnet.public_subnet.id`
- **Key Name**: `aws_key_pair.my_key.key_name`
- **Security Group**: `aws_security_group.web_sg.id`
- **Etiqueta**: `Name = "WebServerInstance"`

Este recurso lanza una instancia EC2 en la subnet pública, configurada con un Key Pair y un grupo de seguridad para acceso seguro.

---

### 10. Security Group para el Servidor Web

#### Recurso: `aws_security_group.web_sg`
- **Nombre**: `web-sg`
- **Descripción**: Permitir tráfico HTTP, HTTPS y SSH
- **VPC ID**: `aws_vpc.main.id`

#### Reglas Ingress:
- **HTTP (puerto 80)**: desde cualquier IP (`0.0.0.0/0`)
- **HTTPS (puerto 443)**: desde cualquier IP (`0.0.0.0/0`)
- **SSH (puerto 22)**: desde cualquier IP (`0.0.0.0/0`)

#### Reglas Egress:
- **Permitir todo el tráfico saliente** (`0.0.0.0/0`)

Este grupo de seguridad permite acceso HTTP, HTTPS y SSH a la instancia EC2, mientras mantiene el tráfico saliente abierto.

---

### 11. Key Pair EC2

#### Generación de Clave Privada: `tls_private_key.ssh_key`
- **Algoritmo**: `RSA`
- **Bits**: `4096`

#### Recurso Key Pair: `aws_key_pair.my_key`
- **Nombre**: `my-ec2-key`
- **Clave Pública**: `tls_private_key.ssh_key.public_key_openssh`

#### Archivo Local: `local_file.private_key`
- **Contenido**: `tls_private_key.ssh_key.private_key_pem`
- **Nombre de archivo**: `${path.module}/my-ec2-key.pem`

Genera un par de claves SSH para acceder a la instancia EC2.

---

### 12. IP Elástica para EC2

#### Recurso: `aws_eip.ec2_eip`
- **Etiqueta**: `Name = "EC2ElasticIP"`

#### Asociación: `aws_eip_association.eip_assoc`
- **Instance ID**: `aws_instance.web_server.id`
- **Allocation ID**: `aws_eip.ec2_eip.id`

Asigna una IP elástica a la instancia EC2, permitiendo acceso persistente a la instancia en la subnet pública.

---
## Contribuciones

1. Realiza un **fork** del proyecto.
2. Crea una nueva **rama** para tus cambios:  
   ```bash
   git checkout -b feature/nueva-funcionalidad
   ```
3. Haz un **commit** con tus cambios y súbelos:  
   ```bash
   git commit -m "Agrega nueva funcionalidad"
   git push origin feature/nueva-funcionalidad
   ```
4. Abre un **pull request**.

---

## Licencia

Este proyecto está disponible bajo la licencia [MIT](https://opensource.org/licenses/MIT). 

---

## Contacto

Si tienes alguna duda o sugerencia, no dudes en abrir un **issue** o contactarme directamente.
