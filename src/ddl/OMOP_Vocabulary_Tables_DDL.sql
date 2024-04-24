CREATE TABLE OMOP.concept (
    concept_id integer NOT NULL,
    concept_name varchar(255) NOT NULL,
    domain_id varchar(20) NOT NULL,
    vocabulary_id varchar(20) NOT NULL,
    concept_class_id varchar(20) NOT NULL,
    standard_concept varchar(1),
    concept_code varchar(50) NOT NULL,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason varchar(1)
)

GO

CREATE TABLE OMOP.concept_ancestor (
    ancestor_concept_id integer NOT NULL,
    descendant_concept_id integer NOT NULL,
    min_levels_of_separation integer NOT NULL,
    max_levels_of_separation integer NOT NULL
)

GO

CREATE TABLE OMOP.concept_class (
    concept_class_id varchar(20) NOT NULL,
    concept_class_name varchar(255) NOT NULL,
    concept_class_concept_id integer NOT NULL
)

GO

CREATE TABLE OMOP.concept_relationship (
    concept_id_1 integer NOT NULL,
    concept_id_2 integer NOT NULL,
    relationship_id varchar(20) NOT NULL,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason varchar(1)
)

GO

CREATE TABLE OMOP.concept_synonym (
    concept_id integer NOT NULL,
    concept_synonym_name varchar(1000) NOT NULL,
    language_concept_id integer NOT NULL
)

GO

CREATE TABLE OMOP."domain" (
    domain_id varchar(20) NOT NULL,
    domain_name varchar(255) NOT NULL,
    domain_concept_id integer NOT NULL
)

GO

CREATE TABLE OMOP.drug_strength (
    drug_concept_id integer NOT NULL,
    ingredient_concept_id integer NOT NULL,
    amount_value numeric,
    amount_unit_concept_id integer,
    numerator_value numeric,
    numerator_unit_concept_id integer,
    denominator_value numeric,
    denominator_unit_concept_id integer,
    box_size integer,
    valid_start_date date NOT NULL,
    valid_end_date date NOT NULL,
    invalid_reason varchar(1)
)

GO

CREATE TABLE OMOP.relationship (
    relationship_id varchar(20) NOT NULL,
    relationship_name varchar(255) NOT NULL,
    is_hierarchical varchar(1) NOT NULL,
    defines_ancestry varchar(1) NOT NULL,
    reverse_relationship_id varchar(20) NOT NULL,
    relationship_concept_id integer NOT NULL
)

GO

CREATE TABLE OMOP.vocabulary (
    vocabulary_id varchar(20) NOT NULL,
    vocabulary_name varchar(255) NOT NULL,
    vocabulary_reference varchar(255),
    vocabulary_version varchar(255),
    vocabulary_concept_id integer NOT NULL
)

GO

ALTER TABLE OMOP.concept
    ADD CONSTRAINT xpk_concept PRIMARY KEY (concept_id)
GO

ALTER TABLE OMOP.concept_ancestor
    ADD CONSTRAINT xpk_concept_ancestor PRIMARY KEY (ancestor_concept_id, descendant_concept_id)
GO

ALTER TABLE OMOP.concept_class
    ADD CONSTRAINT xpk_concept_class PRIMARY KEY (concept_class_id)
GO

ALTER TABLE OMOP.concept_relationship
    ADD CONSTRAINT xpk_concept_relationship PRIMARY KEY (concept_id_1, concept_id_2, relationship_id)
GO

ALTER TABLE OMOP."domain"
    ADD CONSTRAINT xpk_domain PRIMARY KEY (domain_id)
GO

ALTER TABLE OMOP.drug_strength
    ADD CONSTRAINT xpk_drug_strength PRIMARY KEY (drug_concept_id, ingredient_concept_id)
GO

ALTER TABLE OMOP.relationship
    ADD CONSTRAINT xpk_relationship PRIMARY KEY (relationship_id)
GO

ALTER TABLE OMOP.vocabulary
    ADD CONSTRAINT xpk_vocabulary PRIMARY KEY (vocabulary_id)
GO

CREATE INDEX idx_concept_ancestor_id_1 ON OMOP.concept_ancestor (ancestor_concept_id)
GO

CREATE INDEX idx_concept_ancestor_id_2 ON OMOP.concept_ancestor (descendant_concept_id)
GO

CREATE UNIQUE INDEX idx_concept_class_class_id ON OMOP.concept_class (concept_class_id)
GO

CREATE INDEX idx_concept_class_id ON OMOP.concept (concept_class_id)
GO

CREATE INDEX idx_concept_code ON OMOP.concept (concept_code)
GO

CREATE UNIQUE INDEX idx_concept_concept_id ON OMOP.concept (concept_id)
GO

CREATE INDEX idx_concept_domain_id ON OMOP.concept (domain_id)
GO

CREATE INDEX idx_concept_relationship_id_1 ON OMOP.concept_relationship (concept_id_1)
GO

CREATE INDEX idx_concept_relationship_id_2 ON OMOP.concept_relationship (concept_id_2)
GO

CREATE INDEX idx_concept_relationship_id_3 ON OMOP.concept_relationship (relationship_id)
GO

CREATE INDEX idx_concept_synonym_id ON OMOP.concept_synonym (concept_id)
GO

CREATE INDEX idx_concept_vocabluary_id ON OMOP.concept (vocabulary_id)
GO

CREATE UNIQUE INDEX idx_domain_domain_id ON OMOP."domain" (domain_id)
GO

CREATE INDEX idx_drug_strength_id_1 ON OMOP.drug_strength (drug_concept_id)
GO

CREATE INDEX idx_drug_strength_id_2 ON OMOP.drug_strength (ingredient_concept_id)
GO

CREATE UNIQUE INDEX idx_relationship_rel_id ON OMOP.relationship (relationship_id)
GO

CREATE UNIQUE INDEX idx_vocabulary_vocabulary_id ON OMOP.vocabulary (vocabulary_id)
GO

ALTER TABLE OMOP.concept_ancestor
    ADD CONSTRAINT fpk_concept_ancestor_concept_1 FOREIGN KEY (ancestor_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.concept_ancestor
    ADD CONSTRAINT fpk_concept_ancestor_concept_2 FOREIGN KEY (descendant_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.concept
    ADD CONSTRAINT fpk_concept_class FOREIGN KEY (concept_class_id) REFERENCES OMOP.concept_class(concept_class_id)
GO

ALTER TABLE OMOP.concept_class
    ADD CONSTRAINT fpk_concept_class_concept FOREIGN KEY (concept_class_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.concept
    ADD CONSTRAINT fpk_concept_domain FOREIGN KEY (domain_id) REFERENCES OMOP."domain"(domain_id)
GO

ALTER TABLE OMOP.concept_relationship
    ADD CONSTRAINT fpk_concept_relationship_c_1 FOREIGN KEY (concept_id_1) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.concept_relationship
    ADD CONSTRAINT fpk_concept_relationship_c_2 FOREIGN KEY (concept_id_2) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.concept_relationship
    ADD CONSTRAINT fpk_concept_relationship_id FOREIGN KEY (relationship_id) REFERENCES OMOP.relationship(relationship_id)
GO

ALTER TABLE OMOP.concept_synonym
    ADD CONSTRAINT fpk_concept_synonym_concept FOREIGN KEY (concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.concept
    ADD CONSTRAINT fpk_concept_vocabulary FOREIGN KEY (vocabulary_id) REFERENCES OMOP.vocabulary(vocabulary_id)
GO

ALTER TABLE OMOP."domain"
    ADD CONSTRAINT fpk_domain_concept FOREIGN KEY (domain_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.drug_strength
    ADD CONSTRAINT fpk_drug_strength_concept_1 FOREIGN KEY (drug_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.drug_strength
    ADD CONSTRAINT fpk_drug_strength_concept_2 FOREIGN KEY (ingredient_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.drug_strength
    ADD CONSTRAINT fpk_drug_strength_unit_1 FOREIGN KEY (amount_unit_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.drug_strength
    ADD CONSTRAINT fpk_drug_strength_unit_2 FOREIGN KEY (numerator_unit_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.drug_strength
    ADD CONSTRAINT fpk_drug_strength_unit_3 FOREIGN KEY (denominator_unit_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.relationship
    ADD CONSTRAINT fpk_relationship_concept FOREIGN KEY (relationship_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.relationship
    ADD CONSTRAINT fpk_relationship_reverse FOREIGN KEY (reverse_relationship_id) REFERENCES OMOP.relationship(relationship_id)
GO

ALTER TABLE OMOP.vocabulary
    ADD CONSTRAINT fpk_vocabulary_concept FOREIGN KEY (vocabulary_concept_id) REFERENCES OMOP.concept(concept_id)
GO
