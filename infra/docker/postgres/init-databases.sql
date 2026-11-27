-- Exécuté une seule fois, au tout premier démarrage de Postgres.
-- La base "airflow" est créée par la variable POSTGRES_DB du docker-compose.
-- Ici, on crée la base analytique du projet.

CREATE DATABASE warehouse;
