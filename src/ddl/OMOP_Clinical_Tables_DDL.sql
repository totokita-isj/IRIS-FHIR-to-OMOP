CREATE TABLE OMOP.care_site (
    care_site_id bigint PRIMARY KEY NOT NULL,
    care_site_name varchar(255),
    place_of_service_concept_id integer,
    location_id integer,
    care_site_source_value varchar(50),
    place_of_service_source_value varchar(50)
)

GO

CREATE TABLE OMOP.condition_occurrence (
    condition_occurrence_id bigint PRIMARY KEY NOT NULL,
    person_id integer NOT NULL,
    condition_concept_id integer NOT NULL,
    condition_start_date date NOT NULL,
    condition_start_datetime datetime,
    condition_end_date date,
    condition_end_datetime datetime,
    condition_type_concept_id integer NOT NULL,
    condition_status_concept_id integer,
    stop_reason varchar(20),
    provider_id integer,
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    condition_source_value varchar(50),
    condition_source_concept_id integer,
    condition_status_source_value varchar(50)
)

GO

CREATE TABLE OMOP.drug_exposure (
    drug_exposure_id bigint PRIMARY KEY NOT NULL,
    person_id integer NOT NULL,
    drug_concept_id integer NOT NULL,
    drug_exposure_start_date date NOT NULL,
    drug_exposure_start_datetime datetime,
    drug_exposure_end_date date,
    drug_exposure_end_datetime datetime,
    verbatim_end_date date,
    drug_type_concept_id integer NOT NULL,
    stop_reason varchar(20),
    refills integer,
    quantity numeric,
    days_supply integer,
    sig text,
    route_concept_id integer,
    effective_drug_dose numeric,
    dose_unit_concept_id integer,
    lot_number varchar(50),
    provider_id integer,
    visit_occurrence_id integer,
    visit_detail_id integer,
    drug_source_value varchar(50),
    drug_source_concept_id integer,
    route_source_value varchar(50),
    dose_unit_source_value varchar(50)
)

GO

CREATE TABLE OMOP.location (
    location_id bigint PRIMARY KEY NOT NULL,
    address_1 varchar(50),
    address_2 varchar(50),
    city varchar(50),
    state varchar(2),
    zip varchar(9),
    county varchar(20),
    location_source_value varchar(50),
    country_concept_id integer,
    country_source_value varchar(80),
    latitude numeric,
    longitude numeric
)

GO

CREATE TABLE OMOP.measurement (
    measurement_id bigint PRIMARY KEY NOT NULL,
    person_id integer NOT NULL,
    measurement_concept_id integer NOT NULL,
    measurement_date date NOT NULL,
    measurement_datetime datetime,
    measurement_time varchar(10),
    measurement_type_concept_id integer NOT NULL,
    operator_concept_id integer,
    value_as_number numeric,
    value_as_concept_id integer,
    unit_concept_id integer,
    range_low numeric,
    range_high numeric,
    provider_id integer,
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    measurement_source_value varchar(50),
    measurement_source_concept_id integer,
    unit_source_value varchar(50),
    unit_source_concept_id integer,
    value_source_value varchar(50),
    measurement_event_id integer,
    meas_event_field_concept_id integer
)

GO

CREATE TABLE OMOP.observation (
    observation_id bigint PRIMARY KEY NOT NULL,
    person_id integer NOT NULL,
    observation_concept_id integer NOT NULL,
    observation_date date NOT NULL,
    observation_datetime datetime,
    observation_type_concept_id integer NOT NULL,
    value_as_number numeric,
    value_as_string varchar(60),
    value_as_concept_id integer,
    qualifier_concept_id integer,
    unit_concept_id integer,
    provider_id integer,
    visit_occurrence_id integer,
    visit_detail_id integer,
    observation_source_value varchar(50),
    observation_source_concept_id integer,
    unit_source_value varchar(50),
    qualifier_source_value varchar(50),
    value_source_value varchar(50),
    observation_event_id integer,
    obs_event_field_concept_id integer
)

GO

CREATE TABLE OMOP.observation_period (
    observation_period_id bigint PRIMARY KEY NOT NULL,
    person_id integer NOT NULL,
    observation_period_start_date date NOT NULL,
    observation_period_end_date date NOT NULL,
    period_type_concept_id integer NOT NULL
)

GO

CREATE TABLE OMOP.person (
    person_id bigint PRIMARY KEY NOT NULL,
    gender_concept_id integer NOT NULL,
    year_of_birth integer NOT NULL,
    month_of_birth integer,
    day_of_birth integer,
    birth_datetime datetime,
    race_concept_id integer NOT NULL,
    ethnicity_concept_id integer NOT NULL,
    location_id integer,
    provider_id integer,
    care_site_id integer,
    person_source_value varchar(50),
    gender_source_value varchar(50),
    gender_source_concept_id integer,
    race_source_value varchar(50),
    race_source_concept_id integer,
    ethnicity_source_value varchar(50),
    ethnicity_source_concept_id integer
)

GO

CREATE TABLE OMOP.procedure_occurrence (
    procedure_occurrence_id bigint PRIMARY KEY NOT NULL,
    person_id integer NOT NULL,
    procedure_concept_id integer NOT NULL,
    procedure_date date NOT NULL,
    procedure_datetime datetime,
    procedure_end_date date,
    procedure_end_datetime datetime,
    procedure_type_concept_id integer NOT NULL,
    modifier_concept_id integer,
    quantity integer,
    provider_id integer,
    visit_occurrence_id bigint,
    visit_detail_id bigint,
    procedure_source_value varchar(50),
    procedure_source_concept_id integer,
    modifier_source_value varchar(50)
)

GO

CREATE TABLE OMOP.provider (
    provider_id bigint PRIMARY KEY NOT NULL,
    provider_name varchar(255),
    npi varchar(20),
    dea varchar(20),
    specialty_concept_id integer,
    care_site_id integer,
    year_of_birth integer,
    gender_concept_id integer,
    provider_source_value varchar(50),
    specialty_source_value varchar(50),
    specialty_source_concept_id integer,
    gender_source_value varchar(50),
    gender_source_concept_id integer
)

GO

CREATE TABLE OMOP.visit_occurrence (
    visit_occurrence_id bigint PRIMARY KEY NOT NULL,
    person_id integer NOT NULL,
    visit_concept_id integer NOT NULL,
    visit_start_date date NOT NULL,
    visit_start_datetime datetime,
    visit_end_date date NOT NULL,
    visit_end_datetime datetime,
    visit_type_concept_id integer NOT NULL,
    provider_id integer,
    care_site_id integer,
    visit_source_value varchar(50),
    visit_source_concept_id integer,
    admitted_from_concept_id integer,
    admitted_from_source_value varchar(50),
    discharged_to_concept_id integer,
    discharged_to_source_value varchar(50),
    preceding_visit_occurrence_id integer
)

GO

CREATE INDEX idx_condition_concept_id ON OMOP.condition_occurrence (condition_concept_id)
GO

CREATE INDEX idx_condition_person_id ON OMOP.condition_occurrence (person_id)
GO

CREATE INDEX idx_condition_visit_id ON OMOP.condition_occurrence (visit_occurrence_id)
GO

CREATE INDEX idx_drug_concept_id ON OMOP.drug_exposure (drug_concept_id)
GO

CREATE INDEX idx_drug_person_id ON OMOP.drug_exposure (person_id)
GO

CREATE INDEX idx_drug_visit_id ON OMOP.drug_exposure (visit_occurrence_id)
GO

CREATE INDEX idx_measurement_concept_id ON OMOP.measurement (measurement_concept_id)
GO

CREATE INDEX idx_measurement_person_id ON OMOP.measurement (person_id)
GO

CREATE INDEX idx_measurement_visit_id ON OMOP.measurement (visit_occurrence_id)
GO

CREATE INDEX idx_observation_concept_id ON OMOP.observation (observation_concept_id)
GO

CREATE INDEX idx_observation_period_id ON OMOP.observation_period (person_id)
GO

CREATE INDEX idx_observation_person_id ON OMOP.observation (person_id)
GO

CREATE INDEX idx_observation_visit_id ON OMOP.observation (visit_occurrence_id)
GO

CREATE UNIQUE INDEX idx_person_id ON OMOP.person (person_id)
GO

CREATE INDEX idx_procedure_concept_id ON OMOP.procedure_occurrence (procedure_concept_id)
GO

CREATE INDEX idx_procedure_person_id ON OMOP.procedure_occurrence (person_id)
GO

CREATE INDEX idx_procedure_visit_id ON OMOP.procedure_occurrence (visit_occurrence_id)
GO

CREATE INDEX idx_visit_concept_id ON OMOP.visit_occurrence (visit_concept_id)
GO

CREATE INDEX idx_visit_person_id ON OMOP.visit_occurrence (person_id)
GO

ALTER TABLE OMOP.condition_occurrence
    ADD CONSTRAINT fpk_condition_concept FOREIGN KEY (condition_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.condition_occurrence
    ADD CONSTRAINT fpk_condition_concept_s FOREIGN KEY (condition_source_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.condition_occurrence
    ADD CONSTRAINT fpk_condition_person FOREIGN KEY (person_id) REFERENCES OMOP.person(person_id)
GO

ALTER TABLE OMOP.condition_occurrence
    ADD CONSTRAINT fpk_condition_provider FOREIGN KEY (provider_id) REFERENCES OMOP.provider(provider_id)
GO

ALTER TABLE OMOP.condition_occurrence
    ADD CONSTRAINT fpk_condition_type_concept FOREIGN KEY (condition_type_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.condition_occurrence
    ADD CONSTRAINT fpk_condition_visit FOREIGN KEY (visit_occurrence_id) REFERENCES OMOP.visit_occurrence(visit_occurrence_id)
GO

ALTER TABLE OMOP.drug_exposure
    ADD CONSTRAINT fpk_drug_concept FOREIGN KEY (drug_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.drug_exposure
    ADD CONSTRAINT fpk_drug_concept_s FOREIGN KEY (drug_source_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.drug_exposure
    ADD CONSTRAINT fpk_drug_dose_unit_concept FOREIGN KEY (dose_unit_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.drug_exposure
    ADD CONSTRAINT fpk_drug_person FOREIGN KEY (person_id) REFERENCES OMOP.person(person_id)
GO

ALTER TABLE OMOP.drug_exposure
    ADD CONSTRAINT fpk_drug_provider FOREIGN KEY (provider_id) REFERENCES OMOP.provider(provider_id)
GO

ALTER TABLE OMOP.drug_exposure
    ADD CONSTRAINT fpk_drug_route_concept FOREIGN KEY (route_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.drug_exposure
    ADD CONSTRAINT fpk_drug_type_concept FOREIGN KEY (drug_type_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.drug_exposure
    ADD CONSTRAINT fpk_drug_visit FOREIGN KEY (visit_occurrence_id) REFERENCES OMOP.visit_occurrence(visit_occurrence_id)
GO

ALTER TABLE OMOP.measurement
    ADD CONSTRAINT fpk_measurement_concept FOREIGN KEY (measurement_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.measurement
    ADD CONSTRAINT fpk_measurement_concept_s FOREIGN KEY (measurement_source_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.measurement
    ADD CONSTRAINT fpk_measurement_operator FOREIGN KEY (operator_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.measurement
    ADD CONSTRAINT fpk_measurement_person FOREIGN KEY (person_id) REFERENCES OMOP.person(person_id)
GO

ALTER TABLE OMOP.measurement
    ADD CONSTRAINT fpk_measurement_provider FOREIGN KEY (provider_id) REFERENCES OMOP.provider(provider_id)
GO

ALTER TABLE OMOP.measurement
    ADD CONSTRAINT fpk_measurement_type_concept FOREIGN KEY (measurement_type_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.measurement
    ADD CONSTRAINT fpk_measurement_unit FOREIGN KEY (unit_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.measurement
    ADD CONSTRAINT fpk_measurement_value FOREIGN KEY (value_as_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.measurement
    ADD CONSTRAINT fpk_measurement_visit FOREIGN KEY (visit_occurrence_id) REFERENCES OMOP.visit_occurrence(visit_occurrence_id)
GO

ALTER TABLE OMOP.observation
    ADD CONSTRAINT fpk_observation_concept FOREIGN KEY (observation_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.observation
    ADD CONSTRAINT fpk_observation_concept_s FOREIGN KEY (observation_source_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.observation_period
    ADD CONSTRAINT fpk_observation_period_concept FOREIGN KEY (period_type_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.observation_period
    ADD CONSTRAINT fpk_observation_period_person FOREIGN KEY (person_id) REFERENCES OMOP.person(person_id)
GO

ALTER TABLE OMOP.observation
    ADD CONSTRAINT fpk_observation_person FOREIGN KEY (person_id) REFERENCES OMOP.person(person_id)
GO

ALTER TABLE OMOP.observation
    ADD CONSTRAINT fpk_observation_provider FOREIGN KEY (provider_id) REFERENCES OMOP.provider(provider_id)
GO

ALTER TABLE OMOP.observation
    ADD CONSTRAINT fpk_observation_qualifier FOREIGN KEY (qualifier_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.observation
    ADD CONSTRAINT fpk_observation_type_concept FOREIGN KEY (observation_type_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.observation
    ADD CONSTRAINT fpk_observation_unit FOREIGN KEY (unit_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.observation
    ADD CONSTRAINT fpk_observation_value FOREIGN KEY (value_as_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.observation
    ADD CONSTRAINT fpk_observation_visit FOREIGN KEY (visit_occurrence_id) REFERENCES OMOP.visit_occurrence(visit_occurrence_id)
GO

ALTER TABLE OMOP.person
    ADD CONSTRAINT fpk_person_care_site FOREIGN KEY (care_site_id) REFERENCES OMOP.care_site(care_site_id)
GO

ALTER TABLE OMOP.person
    ADD CONSTRAINT fpk_person_ethnicity_concept FOREIGN KEY (ethnicity_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.person
    ADD CONSTRAINT fpk_person_ethnicity_concept_s FOREIGN KEY (ethnicity_source_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.person
    ADD CONSTRAINT fpk_person_gender_concept FOREIGN KEY (gender_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.person
    ADD CONSTRAINT fpk_person_gender_concept_s FOREIGN KEY (gender_source_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.person
    ADD CONSTRAINT fpk_person_location FOREIGN KEY (location_id) REFERENCES OMOP.location(location_id)
GO

ALTER TABLE OMOP.person
    ADD CONSTRAINT fpk_person_provider FOREIGN KEY (provider_id) REFERENCES OMOP.provider(provider_id)
GO

ALTER TABLE OMOP.person
    ADD CONSTRAINT fpk_person_race_concept FOREIGN KEY (race_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.person
    ADD CONSTRAINT fpk_person_race_concept_s FOREIGN KEY (race_source_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_concept FOREIGN KEY (procedure_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_concept_s FOREIGN KEY (procedure_source_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_modifier FOREIGN KEY (modifier_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_person FOREIGN KEY (person_id) REFERENCES OMOP.person(person_id)
GO

ALTER TABLE OMOP.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_provider FOREIGN KEY (provider_id) REFERENCES OMOP.provider(provider_id)
GO

ALTER TABLE OMOP.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_type_concept FOREIGN KEY (procedure_type_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.procedure_occurrence
    ADD CONSTRAINT fpk_procedure_visit FOREIGN KEY (visit_occurrence_id) REFERENCES OMOP.visit_occurrence(visit_occurrence_id)
GO

ALTER TABLE OMOP.provider
    ADD CONSTRAINT fpk_provider_care_site FOREIGN KEY (care_site_id) REFERENCES OMOP.care_site(care_site_id)
GO

ALTER TABLE OMOP.provider
    ADD CONSTRAINT fpk_provider_gender FOREIGN KEY (gender_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.provider
    ADD CONSTRAINT fpk_provider_gender_s FOREIGN KEY (gender_source_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.provider
    ADD CONSTRAINT fpk_provider_specialty FOREIGN KEY (specialty_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.provider
    ADD CONSTRAINT fpk_provider_specialty_s FOREIGN KEY (specialty_source_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.visit_occurrence
    ADD CONSTRAINT fpk_visit_care_site FOREIGN KEY (care_site_id) REFERENCES OMOP.care_site(care_site_id)
GO

ALTER TABLE OMOP.visit_occurrence
    ADD CONSTRAINT fpk_visit_concept FOREIGN KEY (visit_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.visit_occurrence
    ADD CONSTRAINT fpk_visit_concept_s FOREIGN KEY (visit_source_concept_id) REFERENCES OMOP.concept(concept_id)
GO

ALTER TABLE OMOP.visit_occurrence
    ADD CONSTRAINT fpk_visit_person FOREIGN KEY (person_id) REFERENCES OMOP.person(person_id)
GO

ALTER TABLE OMOP.visit_occurrence
    ADD CONSTRAINT fpk_visit_provider FOREIGN KEY (provider_id) REFERENCES OMOP.provider(provider_id)
GO

ALTER TABLE OMOP.visit_occurrence
    ADD CONSTRAINT fpk_visit_type_concept FOREIGN KEY (visit_type_concept_id) REFERENCES OMOP.concept(concept_id)
GO
