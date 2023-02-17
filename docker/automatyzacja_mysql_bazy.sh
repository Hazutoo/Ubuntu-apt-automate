#!/bin/bash

USER="root"

while true
do
    # pobranie nazwy bazy danych do skopiowania
    read -p "Podaj nazwę bazy danych, którą chcesz skopiować (lub wpisz 'exit', aby wyjść z programu): " DB_NAME

    # sprawdzenie, czy użytkownik chce wyjść z programu
    if [ "$DB_NAME" = "exit" ]
    then
        exit 0
    fi

    # pobranie nowej nazwy dla skopiowanej bazy
    read -p "Podaj nową nazwę dla skopiowanej bazy: " NEW_DB_NAME

    # ścieżka do pliku z dumpem
    DUMP_PATH="/tmp/$DB_NAME.sql"

    # utworzenie dumpa bazy danych
    sudo mysqldump -u $USER $DB_NAME > $DUMP_PATH

    # utworzenie nowej bazy danych
    sudo mysql -u $USER -e "CREATE DATABASE $NEW_DB_NAME;"

    # nadanie uprawnień do nowej bazy danych
    # sudo mysql -u $USER -e "GRANT ALL PRIVILEGES ON $NEW_DB_NAME.* TO '$USER'@'localhost';"

    # =================================================================================
    # Dla deva nadajemy takie uprawnienia (do edycji i weryfikacji przed użyciem skryptu): 
    # grant select on $NEW_DB_NAME.* to 'syliusreadonly'@'%';
    # grant all privileges on $NEW_DB_NAME.* to 'sylius'@'%';
    # flush privileges;

    # wgranie dumpa bazy danych do nowej bazy
    sudo mysql -u $USER $NEW_DB_NAME < $DUMP_PATH

    # wyświetlenie nazwy nowej bazy danych po wgraniu
    echo "Kopia bazy danych $DB_NAME została zapisana jako $NEW_DB_NAME."

    # wyświetlenie baz danych oraz tabel w nowej bazie danych
    echo Podaj hasło 
    sudo mysql -u root -p -e "show databases;"
    sudo mysql -u root -p -e "show tables;" $NEW_DB_NAME

    # zapytanie użytkownika, czy chce utworzyć kolejną kopię bazy
    read -p "Czy chcesz utworzyć kolejną kopię bazy danych? (tak/nie): " CONTINUE
    if [ "$CONTINUE" = "nie" ]
    then
        exit 0
    fi
done