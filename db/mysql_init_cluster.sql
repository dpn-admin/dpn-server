
DROP DATABASE IF EXISTS dpn_cluster_aptrust;
CREATE DATABASE dpn_cluster_aptrust
    DEFAULT CHARACTER SET utf8
    DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON dpn_cluster_aptrust.*
  TO 'dpnAdmin'@'localhost' IDENTIFIED BY 'dpnPass';

DROP DATABASE IF EXISTS dpn_cluster_chron;
CREATE DATABASE dpn_cluster_chron
    DEFAULT CHARACTER SET utf8
    DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON dpn_cluster_chron.*
  TO 'dpnAdmin'@'localhost' IDENTIFIED BY 'dpnPass';

DROP DATABASE IF EXISTS dpn_cluster_hathi;
CREATE DATABASE dpn_cluster_hathi
    DEFAULT CHARACTER SET utf8
    DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON dpn_cluster_hathi.*
  TO 'dpnAdmin'@'localhost' IDENTIFIED BY 'dpnPass';

DROP DATABASE IF EXISTS dpn_cluster_sdr;
CREATE DATABASE dpn_cluster_sdr
    DEFAULT CHARACTER SET utf8
    DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON dpn_cluster_sdr.*
  TO 'dpnAdmin'@'localhost' IDENTIFIED BY 'dpnPass';

DROP DATABASE IF EXISTS dpn_cluster_tdr;
CREATE DATABASE dpn_cluster_tdr
    DEFAULT CHARACTER SET utf8
    DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON dpn_cluster_tdr.*
  TO 'dpnAdmin'@'localhost' IDENTIFIED BY 'dpnPass';
