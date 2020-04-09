CREATE USER 'redcraft-laravel'@'10.%.%.%';
CREATE USER 'redcraft-minecraft'@'10.%.%.%';
CREATE USER 'redcraft-overviewer'@'10.%.%.%';

GRANT ALL PRIVILEGES ON *.* TO 'redcraft-laravel'@'10.%.%.%';
GRANT ALL PRIVILEGES ON *.* TO 'redcraft-minecraft'@'10.%.%.%';
GRANT ALL PRIVILEGES ON *.* TO 'redcraft-overviewer'@'10.%.%.%';

CREATE USER 'root'@'10.%.%.%';

GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.%.%.%';