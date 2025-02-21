# Automatisation de la Création de Données à partir de Fichiers Excel avec Ruby

## Prérequis

Avant de lancer le script Ruby `main.rb`, assurez-vous que vous avez configuré correctement votre fichier `.env` et que vous avez installé les dépendances nécessaires.

### Configuration du fichier `.env`

Le fichier `.env` contient les informations de connexion à votre base de données PostgreSQL. Créez un fichier `.env` à la racine de votre projet et ajoutez-y les informations suivantes :

```shell
DB_HOST=localhost
DB_USER=postgres
DB_NAME=your_database_name
DB_PASSWORD=your_password
```

### Installation des dépendances

Pour installer les dépendances, exécutez la commande suivante :

```shell
 gem install pg
 gem install rubyXL
 gem dotenv  
```

## Utilisation

Pour lancer le script Ruby `main.rb`, exécutez la commande suivante :

```shell
ruby main.rb
```

avec les argument suivant ->

```shell
ruby main.rb -f path/to/excel/file.xlsx
```

pour le mode debug
```shell
-debug | -d
```

pour avoir de l'aide
```shell
-help | -h
```

