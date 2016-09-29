
DROP DATABASE IF EXISTS dpn_test;
CREATE DATABASE dpn_test
    DEFAULT CHARACTER SET utf8
    DEFAULT COLLATE utf8_general_ci;

DROP DATABASE IF EXISTS dpn_development;
CREATE DATABASE dpn_development
    DEFAULT CHARACTER SET utf8
    DEFAULT COLLATE utf8_general_ci;

# DROP USER 'dpnAdmin'@'localhost';
# CREATE USER 'dpnAdmin'@'localhost' IDENTIFIED BY 'dpnPass';
GRANT ALL PRIVILEGES ON dpn_test.*
  TO 'dpnAdmin'@'localhost' IDENTIFIED BY 'dpnPass';
GRANT ALL PRIVILEGES ON dpn_development.*
  TO 'dpnAdmin'@'localhost' IDENTIFIED BY 'dpnPass';
