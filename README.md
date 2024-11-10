# WEBAPP
Este repositorio contiene la documentación y el código de los retos de conocimiento técnico 1 y 2 completados en AWS, incluyendo la implementación de una aplicación web y su despliegue en ECS Fargate. El proyecto se desarrolló con JavaScript y Terraform, y utiliza diversos servicios de AWS para cumplir con los requisitos establecidos.
Descripción del Proyecto
Reto de Conocimiento Técnico 1
Se desarrolló una aplicación web en Docker, posteriormente migrada a AWS ECS. La arquitectura creada incluye:

Una VPC con publicación de servicios a Internet.
Un Clúster ECS Fargate para la ejecución de la aplicación.
Secret Manager para gestionar información sensible.
Un Bucket de S3 para almacenamiento de logs personalizados.
Reto de Conocimiento Técnico 2
Incluye la documentación en formato PDF, los pasos para replicar la arquitectura usando Terraform, y un ejemplo de presupuesto en AWS Calculator para la estimación de costos del servicio Database Migration Service (DMS).

Estructura del Repositorio
/docs: Contiene la documentación en PDF.
/src: Código fuente del proyecto en JavaScript y Terraform.
/infrastructure: Archivos de configuración de Terraform para crear la infraestructura en AWS.
budget_example: Archivo con el ejemplo de presupuesto en AWS Calculator.
Requisitos
Docker: Para ejecutar la aplicación web localmente.
AWS CLI y Terraform: Para gestionar y desplegar la infraestructura en AWS.
Node.js: Para ejecutar el código en JavaScript.
Despliegue en AWS
Compilar y Empaquetar la Aplicación: Construir la imagen Docker de la aplicación y hacer push a Amazon ECR.
Terraform: Utilizar el código en /infrastructure para aprovisionar los recursos en AWS (VPC, ECS Fargate, Secret Manager, S3, etc.).
Configuración de Balanceador de Carga: Configurar el balanceador de carga para distribuir el tráfico.
Gestión de Logs: Asegurar que los logs se almacenen en S3 para su monitorización.
Recomendaciones de Seguridad
Configuración de subredes privadas y políticas de IAM con el principio de menor privilegio.
Encriptación de datos en S3 y uso de HTTPS para el tráfico de red.
Implementación de AWS CloudTrail y CloudWatch para la auditoría y el monitoreo.
Ejemplo de Presupuesto en AWS Calculator
Se proporciona un ejemplo de presupuesto para el servicio DMS, que puede ser utilizado como referencia para futuras migraciones de bases de datos a AWS.
