![image alt ><](https://d2908q01vomqb2.cloudfront.net/77de68daecd823babbb58edb1c8e14d7106e83bb/2018/12/21/Lambda-Layers-1.jpg)

# AWS Lambda Layers: Node JS

Documentacion oficial: [aquí](https://aws.amazon.com/blogs/compute/working-with-aws-lambda-and-lambda-layers-in-aws-sam/)

## Contenido

Aqui se explica la definicion de contrucción de libs y como implementarlas en las funciones lambdas en ambientes Node js
> **NOTA IMPORTANTE**: El contenido de esta carpeta, es solo para desarrollos que en su primera fase, se desplegarán en formato layer
> para las puebras de desarrollo e implementacion estas funciones en las lambdas y luego pasar las funcionalidad como libreria al reposotorio nexus.
>
> Para las funcionalidades que siempre serán layers, realizarlo en el directorio **ROOT_PATH/layers** 

## Estructura de carpetas

Para la inclusion de libs en el despliegue de los proyectos node, es necesario
mantener el siguiente esquema de directorios

```
node
├── custom-layer
│   └── nodejs
│       └── node_modules
│           └── custom-layer
│               ├── index.js
│               ├── package.json
│               └── README.md
├── npm
│   └── nodejs
│       └── package.json
└── README.md

```

Hay que tener las siguientes consideraciones con respecto a esta estructura:

* Los paquetes de npm que se necesiten usar en mas de una lambda deben instalarse en la layer `libs/npm/nodejs`

* Los paquetes de npm que hagan que la lambda supere el peso de visualización en consola (3 MB), deben instalarse en la layer `libs/npm/nodejs`

* Las librerias propias que se desarrollen y son cros lambdas, deben crearse con la estructura `custom-layer/nodejs/node_modules/custom-layer` dentro del directorio `layer/node`, esto es por las siguientes razones:

    * El proceso de inatalacion de libs, se realizará en un unico path, el cual es conocido en el ambiente de la lambda, en este caso es `nodejs/node_modules`

    * Los require de las librerias en el codigo, se realizan directamente por el nombre definido del directorio, ejemplo `require("custom-layer");`

    * Las dependencias npm que se utilice en la custom-layer, se instalan como cualquier otra dibreria `npm install <package-name> --save`

* Al crear una custom-layer, siempre se debe definir `index.js` como el achivo de exportacion de la funcionalidad. [see](https://docs.npmjs.com/about-packages-and-modules#about-modules)

* Una vez instalado un paquete de npm en `libs/npm/nodejs`  y/o creado una custom-libs, es importante no olvidar definir la(s) layer(s) en el cloudformation y añadirla(s) a la(s) lambda(s) que la van a utilizar

## Definicion y uso de layer en CloudFormation

Para esta explicacion se usará lo que esta definido en el repo, lo cual es una leyer para paquetes de **npm** y una custom-layer llamada **logger**.

Esta es la siguiente estructura:

```
node
├── logger
│   └── nodejs
│       └── node_modules
│           └── logger
│               ├── index.js
│               ├── logger.js
│               ├── logger-wrapper.js
│               ├── package.json
│               ├── readLine.js
│               └── README.md
├── npm
│   └── nodejs
│       └── package.json
└── README.md
```

En `node/npm/nodejs/package.json` esta instalado la libreria axios:

```
...
"dependencies": {
    "axios": "^0.19.0"
}
...
```

En `node/logger/nodejs/node_modules/logger` esta nuestra libreria logger y usa como base una libreria npm llamada `winston`
ademas de todas las configuraciones para el sistema de log de lambdas

```
...
"dependencies": {
    "winston": "^3.2.1"
}
...
```

Una vez ya creado esto, definimos 2 libs en el CloudFormation `(root-folder/cloudformations/template.yaml)`

```
Resources:
  # Esta layer contiene las librerias de npm que se quieren compartir cros lambdas en el proyecto
  NodePackageManagerLayer:
    Type: AWS::Serverless::LayerVersion
    Properties:
      LayerName: !Join ['-', [!Ref Environment, !Ref Project, 'NodePackageManagerLayer']]
      ContentUri: ../libs/node/npm
      Description: "layer containing npm libraries: "
      CompatibleRuntimes:
        - nodejs10.x
      RetentionPolicy: Retain
   
  # Esta layer es una configuracion custom para las salidas log de la lambda, tiene
  LoggerLayer:
    Type: AWS::Serverless::LayerVersion
    Properties:
      LayerName: !Join ['-', [!Ref Environment, !Ref Project, 'LoggerLayer']]
      ContentUri: ../libs/node/logger
      Description: "config for log system based on wiston library"
      CompatibleRuntimes:
        - nodejs10.x
      RetentionPolicy: Retain
```

Notese que en ambas definiciones en la propiedad `ContentUri` contiene el path relativo de la layer respectiva

- **../libs/node/npm**
- **../libs/node/logger**

Luego de hacer la definicion, agregamos la referencia a la lambda en la propiedad `Layers` con el nombre logico de la layer:

```
Resources:
  ...
  ...
  HelloWorldFunction:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: !Join ['-', [!Ref Environment, !Ref Project, 'HelloWorld']]
      CodeUri: ../functions/lambda
      Layers:
        - !Ref NodePackageManagerLayer
        - !Ref LoggerLayer
      AutoPublishAlias: ActiveVersion
```

Con esto ya estamos listo para hecer el despliegue usando axios y nuestra funcion logger en la lambda.


## Uso de layer en ambiente local

>NOTA: para el ambiende de desarrollo local es necesario usar **yarn** en lugar de **npm**, debido a que estaremos instalando librerias locales y
al usar **npm**, este crea un link simbolico a ese directorio en vez de hacer una copia del directorio e intalar al mismo nivel las librerias que necesiten. 

Para hacer uso de las layer's ambiente local o para la ejecucion de test solo en necesario instalar el directorio `libs/node/npm/nodejs` y `custom-layer/nodejs/node_modules/custom-layer`
como devDependencies en nuestre lambda, para ello se usa el siguiente comando:

* librerias npm: `yarn add file:../../libs/node/logger/nodejs/node_modules/logger/ -D`
* custom-layer logger: `yarn add file:../../libs/node/npm/nodejs/ -D`

Al hacer esto, queda a nuestra dispocion para importar las librerias y funcinalidades que luego usaremos como layer:

        const axios = require('axios');
        const logger = require('logger')(module);

## Creators

**Nestor Lopes**

**Vladmir Castañeda**


Enjoy :metal:
