#!/bin/bash

function configure_project() {
    echo -n "Nom du projet: "
    read -r p

    # Configuration du certificat
    mkcert -cert-file ~/.certs/$p.test.pem -key-file ~/.certs/$p.test-key.pem $p.test *.$p.test

    # Copie de la configuration des hôtes virtuels
    sudo cp /etc/httpd/conf/vhosts/projet.test /etc/httpd/conf/vhosts/$p.test
    sudo sed -i "s/projet/$p/g" /etc/httpd/conf/vhosts/$p.test
    sudo sed -i "s/htdocs/www/g" /etc/httpd/conf/vhosts/$p.test

    # Création des répertoires du site
    mkdir -p ~/sites/$p.test/www
    mkdir -p ~/sites/$p.test/logs

    # Modification du propriétaire et du groupe dans /srv/http/
    sudo chown -R http:http /srv/http/$p.test

    # Création du lien symbolique
    sudo ln -s ~/sites/$p.test/ /srv/http/

    # Ajout de l'inclusion dans la configuration principale
    echo "Include conf/vhosts/$p.test" | sudo tee -a /etc/httpd/conf/httpd.conf

    # Ajout de l'entrée dans /etc/hosts
    echo "127.0.0.1  www.$p.test" | sudo tee -a /etc/hosts

    # Redémarrage d'Apache
    sudo systemctl restart httpd

    echo "Le projet $p a été configuré avec succès."
}

function remove_project() {
    echo -n "Nom du projet à supprimer: "
    read -r p

    # Suppression des fichiers de configuration
    sudo rm /etc/httpd/conf/vhosts/$p.test

    # Suppression du fichier hosts uniquement s'il contient une entrée pour www.$p.test
    grep -q "www.$p.test" /etc/hosts && sudo sed -i "/www.$p.test/d" /etc/hosts

    # Suppression du lien symbolique
    sudo rm -r /srv/http/$p.test

    # Redémarrage d'Apache
    sudo systemctl restart httpd

    echo "Le projet $p a été supprimé avec succès."
}

# Menu principal
echo "1. Configurer un nouveau projet"
echo "2. Supprimer un projet existant"
echo -n "Choix: "
read -r choice

case $choice in
    1)
        configure_project
        ;;
    2)
        remove_project
        ;;
    *)
        echo "Choix invalide."
        ;;
esac
