# Repositorio Estandares Backend

Este repositorio contiene el template de uso estándar para desarrollos de backend con AWS serverless, utilizando Cloud Formation y SAM.

```code
.
├── README.MD                           <-- Este archivo de instrucciones
├── .gitignore                          <-- Listado de carpetas que Git debe ignorar
├── .editorconfig                       <-- Grupo de reglas para unificar estilos cross-OS
├── cloudformations                     <--
│   └── template.yaml                   <-- Template del stack
│   └── security.yaml                   <-- Roles y accesos del stack
│   └── swagger.yaml                    <-- Estructura del API
├── functions                           <--
│   └── lambda                          <--
│       └── .eslintrc.json              <-- Reglas de calidad de codigo
│       └── .npmignore                  <-- Listado de carpetas que npm debe ignorar
│       └── app.js                      <-- Codigo fuente de la funcion lambda
│       └── package.json                <-- Administracion de dependencias
│       └── yarn.lock                   <-- Listado de dependencias
│       └── test                        <--
│           └── unit.test.js            <-- Tests de unidad de la funcion lambda
│           └── mocks                   <--
│               └── error.json          <-- Mock de payload en caso de error
│               └── event.json          <-- Mock de respuesta
├── scripts                             <--
│   └── deploy_template.sh              <-- Proceso de deploy del template de stack
│   └── deploy_security.sh              <-- Proceso de deploy de roles y accesos del stack
```

## Objetivos del repositorio

El objetivo del repositorio es dar un estándar global de backend, adaptado a todas las etapas del proceso de desarrollo, que integre las buenas prácticas y estándares de arquitectura del sector.

La herramienta principal utilizada es el [CloudFormation](https://aws.amazon.com/es/cloudformation/?nc1=h_ls), sobre la que se basa la arquitectura de este repositorio. Con los recursos que se encuentran en este repositorio se podra deployar un stack en CloudFormation.

Un [stack](https://docs.aws.amazon.com/es_es/AWSCloudFormation/latest/UserGuide/stacks.html) es una colección de recursos de AWS, que pueden administrarse como una única unidad. En otras palabras, pueden crear, actualizar o eliminar una colección de recursos mediante la creación, actualización o eliminación de stacks.

Ademas, se utiliza el framework [AWS SAM](https://docs.aws.amazon.com/es_es/serverless-application-model/latest/developerguide/what-is-sam.html) con el CloudFormation para los despliegues a ambientes.  
GitHub SAM: https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md#globals-section

## Configuración e Uso del repositorio

## /cloudformations

Esta sección contiene la definición del stack para CloudFormation.  
Consta de tres archivos, dos de configuración (template y security) y el tercero la estructura del API (swagger):

### template.yaml

Aquí se definen los recursos a utilizar.

-   Colocar la descripción del stack:

```yaml
Description: >
--DESCRIPCION_STACK--
```

-   Adicionar recursos AWS:

```yaml
Resources: ...
```

Referencia para recursos: https://docs.aws.amazon.com/es_es/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html

-   Configurar outputs (solo en el caso de ser necesarios):

```yaml
Outputs: ...
```

Referencia para outputs: https://docs.aws.amazon.com/es_es/AWSCloudFormation/latest/UserGuide/outputs-section-structure.html

### security.yaml

Aquí se definen los roles y permisos del stack.  
Referencia para IAM: https://docs.aws.amazon.com/es_es/AWSCloudFormation/latest/UserGuide/AWS_IAM.html

### swagger.yaml (solo si se requiere un API)

Contiene documentación y estructura del servicio.  
Template para la creacion de swagger: https://editor.swagger.io/

Se recomienda utilizar el extencion **Swagger Viewer**, un UI para facilitar la creaccion de Swagger:  
https://marketplace.visualstudio.com/items?itemName=Arjun.swagger-viewer

## /functions

En esta carpeta se colocan las [funciones Lambda](https://docs.aws.amazon.com/es_es/lambda/latest/dg/welcome.html) del stack, cada una en su respectiva carpeta.

### /functions/lambda

Esta es una función lambda tipo con la estructura estándar utilizada.
Contiene:

-   .eslintrc: reglas de escritura de código ( ver [Referencia](https://eslint.org/) ).
-   test/: carpeta con los test de unidad y los mocks necesarios ( ver [Anexo](#b) ).
-   package: contiene las dependencias preestablecidas para la creación de tests de unidad ( ver [Anexo](#c) ). Incluye tambien scripts predefinidos ( ver [Anexo](#a) )

## /scripts

Aqui se encuentran los procesos de deploy para la creacion del stack

### deploy_template.sh

Realiza el deploy de la infraestructura del stack de manera local. Lo hace en la cuenta de desarrollo de aws.  
Requiere configurar de manera previa el profile de aws.  
Ejecución:

```bash
bash -x scripts/deploy_template.sh
```

### deploy_security.sh

Realiza el deploy de los permisos del stack de manera local. Lo hace en la cuenta de desarrollo de aws.  
Requiere configurar de manera previa el profile de aws.  
Ejecución:

```bash
bash -x scripts/deploy_security.sh
```

## layers

Contiene toda la estructura de carpetas e instrucciones para el proceso de creacion y despliegue de layers en el proyecto
para mas detalles, [ver aquí](libs/README.md)

# Anexo

## <span id="a">Scripts</span>

La función lambda tipo tiene predefinidos scripts para utilizar las herramientas del estándar:

### lint

Verifica la calidad del código según las reglas preestablecidas y devuelve por consola las anomalías.

### lint:fix

Corrige las anomalías simple encontradas y devuelve por consola las que requieren editar el código.

### test

Corre los tests de unidad de la carpeta test/ de la función.

### coverage

Devuelve por consola la cobertura de código alcanzada por los test de unidad.

### prettier

Modifica la identación de los archivos para que siga el estandar definido por prettier. Su archivo de configuración es .prettierrc

### precommit

Contiene scripts que se ejecutan antes de realizar un commit. Actualmente se usa para ejecutar el linter y prettier. Utiliza lint-staged cuyo archivo de configuración es el .lintstagedrc.json

## <span id="b">Unit Tests</span>

El unit testing es un método de prueba de software en el cual unidades de codigo, grupos de uno o más métodos que funcionan en conjunción con un set común de datos de control, usos y procesos operativos, son testeados para verificar su correcto funcionamiento.  
El repositorio cuenta con un ejemplo de test de unidad (functions/lambda/test) utilizando Mocha + Chai, según los estándares establecidos. Además, existe una carpeta mocks/ donde se ubican los payloads utilizados al mockear servicios.

### Mocha + Chai

Mocha es un framework de prueba y reportería que corre en Node.js, orientado a la metodologia BDD.  
https://mochajs.org/

Chai es una librería de aserciones para Node.js  
https://www.chaijs.com/

## <span id="c">Dependencias preestablecidas para la creación de tests de unidad</span>

### **aws-sdk-mock**

Este módulo fue creado para realizar tests a las funciones AWS Lambda, pero se puede utilizar en cualquier situación donde se necesite mockear el AWS SDK.  
https://www.npmjs.com/package/aws-sdk-mock

### **chai**

Chai es una librería de aserciones, similar a la assert, que viene integrada al Node.  
https://www.npmjs.com/package/chai

### **dotenv**

Dotenv es un módulo que carga variables de ambiente directamente de un .env a process.env.  
https://www.npmjs.com/package/dotenv

### **mocha**

Framework de testing sincrónico para node.js, con reportería y mapeo de excepciones.  
https://mochajs.org/

### **mocha-junit-reporter**

Genera reportes de resultado de tests en XML, con un formato similar a JUnit.  
https://www.npmjs.com/package/mocha-junit-reporter

### **mock-require**

Módulo para el moqueo de statements Require en Node.js.  
https://www.npmjs.com/package/mock-require.

### **nock**

Módulo para el moqueo de requests a un servidor HTTP de manera aislada.  
https://www.npmjs.com/package/nock

### **nyc**

Crea estructura para la visualización de la cobertura.  
https://www.npmjs.com/package/nyc

### **sinon**

Framework para la simulación de callbacks, returns, etc.  
https://sinonjs.org/

### **proxyquire**

Módulo para sobreescribir dependencias durante el testeo.  
https://www.npmjs.com/package/proxyquire
