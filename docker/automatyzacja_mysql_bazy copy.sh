#!/bin/bash

USER="root"

while true
do
    DB_NAME=""
    while ! [[ -n $DB_NAME && $(sudo mysql -u $USER -e "use $DB_NAME" 2>/dev/null) ]]; do
        read -p "Podaj nazwę bazy danych, którą chcesz skopiować: " DB_NAME
        if [[ -z $DB_NAME ]]; then
            echo "Nie podano nazwy bazy danych. Proszę spróbować ponownie."
        elif ! mysql -e "use $DB_NAME" 2>/dev/null; then
            echo "Baza danych o nazwie '$DB_NAME' nie istnieje. Proszę spróbować ponownie."
        fi
        
    done

    # sprawdzenie, czy użytkownik chce wyjść z programu
    if [ "$DB_NAME" = "exit" ]
    then
        exit 0
    fi


    # pobranie nowej nazwy dla skopiowanej bazy
    NEW_DB_NAME=""
    while ! [[ "$NEW_DB_NAME" =~ ^[a-zA-Z0-9_]+$ ]]; do
        read -p "Podaj nową nazwę bazy danych: " NEW_DB_NAME
        if [ -z "$NEW_DB_NAME" ]; then
            echo "Nie podałeś nowej nazwy bazy danych. Spróbuj ponownie."
        elif ! [[ "$NEW_DB_NAME" =~ ^[a-zA-Z0-9_]+$ ]]; then
            echo "Nowa nazwa bazy danych zawiera nieprawidłowe znaki. Spróbuj ponownie."
        fi
    done

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
    echo "Podaj hasło do swojego konta z uprawniniem sudo, aby wyświetlić bazy danych"
    sudo mysql -u root -p -e "show databases;"
    echo "Podaj hasło do swojego konta z uprawniniem sudo, aby wyświetlić tabele zaimportowanej bazy"
    sudo mysql -u root -p -e "show tables;" $NEW_DB_NAME

    # zapytanie użytkownika, czy chce utworzyć kolejną kopię bazy
    while true; do
        read -p "Czy chcesz utworzyć kolejną kopię bazy danych? (tak/nie): " CONTINUE
        case $CONTINUE in
            [Tt][Aa][Kk])
                # Użytkownik wybrał "tak"
                # Tutaj można dodać kod do utworzenia kopii bazy danych
                break
                ;;
            [Nn][Ii][Ee])
                # Użytkownik wybrał "nie"
                exit 0
                ;;
            *)
                # Odpowiedź użytkownika nie jest "tak" ani "nie"
                echo "Proszę odpowiedzieć 'tak' lub 'nie'."
                ;;
        esac
    done

done