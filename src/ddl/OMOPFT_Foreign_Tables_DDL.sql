CREATE FOREIGN SERVER OMOPFT.ForeignServer TYPE 'FILE'
FOREIGN DATA WRAPPER CSV HOST 'C://test/omopfile'

GO

CREATE FOREIGN TABLE OMOPFT.concept
(
    concept_id integer,
    concept_name varchar(255),
    domain_id varchar(20),
    vocabulary_id varchar(20),
    concept_class_id varchar(20),
    standard_concept varchar(1),
    concept_code varchar(50),
    valid_start_date varchar(20), 
    valid_end_date varchar(20),   
    invalid_reason varchar(1)
) SERVER OMOPFT.ForeignServer FILE 'CONCEPT.csv'
USING{ "from": { "file": { "charset": "UTF-8", "columnseparator": "\t", "withoutquotechar": true, "header": true } }, "into": {"jdbc": {"threads": 4} } }

GO

CREATE FOREIGN TABLE OMOPFT.concept_ancestor
(
    ancestor_concept_id integer,
    descendant_concept_id integer,
    min_levels_of_separation integer,
    max_levels_of_separation integer
) SERVER OMOPFT.ForeignServer FILE 'CONCEPT_ANCESTOR.csv'
USING{ "from": { "file": { "charset": "UTF-8", "columnseparator": "\t", "withoutquotechar": true, "header": true } }, "into": {"jdbc": {"threads": 4} } }

GO

CREATE FOREIGN TABLE OMOPFT.concept_class
(
    concept_class_id varchar(20),
    concept_class_name varchar(255),
    concept_class_concept_id integer
) SERVER OMOPFT.ForeignServer FILE 'CONCEPT_CLASS.csv'
USING{ "from": { "file": { "charset": "UTF-8", "columnseparator": "\t", "withoutquotechar": true, "header": true } }, "into": {"jdbc": {"threads": 4} } }

GO

CREATE FOREIGN TABLE OMOPFT.concept_relationship
(
    concept_id_1 integer,
    concept_id_2 integer,
    relationship_id varchar(20),
    valid_start_date varchar(20), 
    valid_end_date varchar(20), 
    invalid_reason varchar(1)
) SERVER OMOPFT.ForeignServer FILE 'CONCEPT_RELATIONSHIP.csv'
USING{ "from": { "file": { "charset": "UTF-8", "columnseparator": "\t", "withoutquotechar": true, "header": true } }, "into": {"jdbc": {"threads": 4} } }

GO

CREATE FOREIGN TABLE OMOPFT.concept_synonym
(
    concept_id integer,
    concept_synonym_name varchar(1000),
    language_concept_id integer
) SERVER OMOPFT.ForeignServer FILE 'CONCEPT_SYNONYM.csv'
USING{ "from": { "file": { "charset": "UTF-8", "columnseparator": "\t", "withoutquotechar": true, "header": true } }, "into": {"jdbc": {"threads": 4} } }

GO

CREATE FOREIGN TABLE OMOPFT."domain"
(
    domain_id varchar(20),
    domain_name varchar(255),
    domain_concept_id integer
) SERVER OMOPFT.ForeignServer FILE 'DOMAIN.csv'
USING{ "from": { "file": { "charset": "UTF-8", "columnseparator": "\t", "withoutquotechar": true, "header": true } }, "into": {"jdbc": {"threads": 4} } }

GO

CREATE FOREIGN TABLE OMOPFT.drug_strength
(
    drug_concept_id integer,
    ingredient_concept_id integer,
    amount_value numeric,
    amount_unit_concept_id integer,
    numerator_value numeric,
    numerator_unit_concept_id integer,
    denominator_value numeric,
    denominator_unit_concept_id integer,
    box_size integer,
    valid_start_date varchar(20), 
    valid_end_date varchar(20), 
    invalid_reason varchar(1)
) SERVER OMOPFT.ForeignServer FILE 'DRUG_STRENGTH.csv'
USING{ "from": { "file": { "charset": "UTF-8", "columnseparator": "\t", "withoutquotechar": true, "header": true } }, "into": {"jdbc": {"threads": 4} } }

GO

CREATE FOREIGN TABLE OMOPFT.relationship
(
    relationship_id varchar(20),
    relationship_name varchar(255),
    is_hierarchical varchar(1),
    defines_ancestry varchar(1),
    reverse_relationship_id varchar(20),
    relationship_concept_id integer
) SERVER OMOPFT.ForeignServer FILE 'RELATIONSHIP.csv'
USING{ "from": { "file": { "charset": "UTF-8", "columnseparator": "\t", "withoutquotechar": true, "header": true } }, "into": {"jdbc": {"threads": 4} } }

GO

CREATE FOREIGN TABLE OMOPFT.vocabulary
(
    vocabulary_id varchar(20),
    vocabulary_name varchar(255),
    vocabulary_reference varchar(255),
    vocabulary_version varchar(255),
    vocabulary_concept_id integer
) SERVER OMOPFT.ForeignServer FILE 'VOCABULARY.csv'
USING{ "from": { "file": { "charset": "UTF-8", "columnseparator": "\t", "withoutquotechar": true, "header": true } }, "into": {"jdbc": {"threads": 4} } }

GO

CREATE FOREIGN TABLE OMOPFT.postalcode
(
    city_code varchar(20),
    postal_code_old varchar(20),
    postal_code varchar(20),
    prefecture_name_kana varchar(255),
    city_name_kana varchar(255),
    town_name_kana varchar(255),
    prefecture_name_kanji varchar(255),
    city_name_kanji varchar(255),
    town_name_kanji varchar(255),
    multi_postalcode_flag integer,
    shoaza_flag integer,
    chomoku_flag integer,
    multi_choiki_flag integer,
    is_updated_flag integer,
    update_reason_code integer    
) SERVER OMOPFT.ForeignServer FILE 'utf_ken_all.csv'
USING{ "from": { "file": { "charset": "UTF-8", "columnseparator": ",", "header": false } }, "into": {"jdbc": {"threads": 4} } }

GO
