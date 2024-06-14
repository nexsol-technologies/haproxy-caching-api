create table postal (
    postname character varying(50) NOT NULL,
    postalcode character(4) NOT NULL,
    postalcode2 character(2) NOT NULL,
    common character varying(50) NOT NULL,
    bfsnumber int NOT NULL,
    canton character varying(50) NULL,
    e float,
    n float,
    lang char(10),
    validity char(10)
);

CREATE INDEX postal_postalcode ON postal (postalcode);
CREATE INDEX postal_common ON postal (common);

COPY postal FROM '/tmp/postal.csv' DELIMITER ';' CSV HEADER;