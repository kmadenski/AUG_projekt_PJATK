# Projekt zaliczeniowy na przedmiot AUG
## Opis
Projekt obejmuje realizację parsera sprawdzającego poprawność zapytań SELECT z domeny języka SQL. 
Zrealizowany został w oparciu o generator parserów https://zaa.ch/jison/
## Kompilacja i uruchomienie
```bash
#Pierwsze uruchomienie
npm install
#Generowanie parsera
./node_modules/jison/lib/cli.js aug_s15540.jison
#Uruchomienie
node aug_s15540.js example.sql
```