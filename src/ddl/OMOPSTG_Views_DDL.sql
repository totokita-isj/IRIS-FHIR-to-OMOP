CREATE OR REPLACE VIEW OMOPSTG.v_location AS
SELECT 
  TO_NUMBER(postal_code) as location_id,
  town_name_kanji as address_1,
  NULL as address_2,
  city_name_kanji as city,
  prefecture_name_kanji as state,
  postal_code as zip,
  NULL as county,
  postal_code as location_source_value,
  4329983 as country_concept_id,
  'Japan' as country_source_value,
  NULL as latitude,
  NULL as longitude
FROM 
  OMOPFT.postalcode 

GO

CREATE OR REPLACE VIEW OMOPSTG.v_care_site AS
SELECT 
  o.ID as care_site_id,
  o.Name as care_site_name,
  NULL as place_of_service_concept_id,
  vl.location_id as location_id,
  o.IdentifierValue as care_site_source_value,
  NULL as place_of_service_source_value
FROM 
  OMOPSBORG.Organization o
  LEFT OUTER JOIN OMOPSTG.v_location vl ON o.AddressPostalCode = vl.zip 

GO

CREATE OR REPLACE VIEW OMOPSTG.v_provider AS
SELECT 
  p.ID as provider_id,
  pn.Text as provider_name,
  NULL as npi,
  NULL as dea,
  0 as specialty_concept_id,
  NULL as care_site_id,
  TO_NUMBER( SUBSTRING(p.BirthDate, 1, 4) ) as year_of_birth,
  CASE 
  	WHEN p.Gender = 'male' THEN 8507
  	WHEN p.Gender = 'female' THEN 8532
  END as gender_concept_id,
  p.IdentifierValue as provider_source_value,
  NULL as specialty_source_value,
  0 as specialty_source_concept_id,
  p.Gender as gender_source_value,
  CASE 
  	WHEN p.Gender = 'male' THEN 8507
  	WHEN p.Gender = 'female' THEN 8532
  END as gender_source_concept_id
FROM
  OMOPSBPRC.Practitioner p
  INNER JOIN OMOPSBPRC.PractitionerName pn ON p.ID = pn.Practitioner
WHERE
  pn.ValueCode = 'IDE'

GO

CREATE OR REPLACE VIEW OMOPSTG.v_person AS
SELECT 
  p.ID as person_id,
  CASE
    WHEN p.Gender = 'male' THEN 8507
    WHEN p.Gender = 'female' THEN 8532
  END as gender_concept_id,
  TO_NUMBER( SUBSTRING(BirthDate,1,4) ) as year_of_birth,
  TO_NUMBER( SUBSTRING(BirthDate,6,2) ) as month_of_birth,
  TO_NUMBER( SUBSTRING(BirthDate,9,2) ) as day_of_birth,
  TO_TIMESTAMP( BirthDate, 'YYYY-MM-DD') as birth_datetime,
  IFNULL( p.Race, 38003584, m.OMOP_Concept_Id ) as race_concept_id,
  38003564 as ethnicity_concept_id,
  vl.location_id as location_id,
  NULL as provider_id,
  NULL as care_site_id,
  p.IdentifierValue as person_source_value,
  p.Gender as gender_source_value,
  CASE
    WHEN p.Gender = 'male' THEN 8507
    WHEN p.Gender = 'female' THEN 8532
  END as gender_source_concept_id,
  IFNULL( p.Race, 'Japanese', p.Race ) as race_source_value,
  IFNULL( p.Race, 38003584, m.OMOP_Concept_Id ) as race_source_concept_id,
  'Not Hispanic or Latino' as ethnicity_source_value,
  38003564 as ethnicity_source_concept_id
FROM %INORDER
  OMOPSBPAT.Patient p
  INNER JOIN OMOPSBPAT.PatientName pn ON pn.Patient = p.ID
  LEFT OUTER JOIN OMOPSTG.v_location vl ON vl.zip = p.AddressPostalCode
  LEFT OUTER JOIN OMOPDTL.F2OMap m ON m.Key = 'PatientRace' AND p.Race = m.Source_Code
WHERE 
  pn.NameCode = 'IDE'

GO

CREATE OR REPLACE VIEW OMOPSTG.v_observation_period AS
SELECT
  enc.ID as observation_period_id,  
  pat.ID as person_id,
  CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(enc.PeriodStart, 20, 3) ), CAST( SUBSTRING(enc.PeriodStart, 1, 10) || ' ' || SUBSTRING(enc.PeriodStart, 12, 8) As TIMESTAMP) ) AS DATE) as  observation_period_start_date,
  CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(enc.PeriodEnd, 20, 3) ), CAST( SUBSTRING(enc.PeriodEnd, 1, 10) || ' ' || SUBSTRING(enc.PeriodEnd, 12, 8) As TIMESTAMP) ) AS DATE) as  observation_period_end_date,
  32817 as period_type_concept_id
FROM 
  OMOPSBENC.Encounter enc
  LEFT OUTER JOIN OMOPSBPAT.Patient pat ON enc.SubjectReference = 'Patient/' || pat.IdentifierValue 
GO
CREATE OR REPLACE VIEW OMOPSTG.v_visit_occurrence AS
SELECT  e.ServiceProviderReference,
  e.ID as visit_occurrence_id,
  p.ID as person_id,
  m.OMOP_Concept_Id as visit_concept_id,
  CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(e.PeriodStart, 20, 3) ), CAST( SUBSTRING(e.PeriodStart, 1, 10) || ' ' || SUBSTRING(e.PeriodStart, 12, 8) As TIMESTAMP) ) as DATE ) as visit_start_date,
  DATEADD( 'hour', TO_NUMBER( SUBSTRING(e.PeriodStart, 20, 3) ), CAST( SUBSTRING(e.PeriodStart, 1, 10) || ' ' || SUBSTRING(e.PeriodStart, 12, 8) As TIMESTAMP) ) as visit_start_datetime,
  CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(e.PeriodEnd, 20, 3) ), CAST( SUBSTRING(e.PeriodEnd, 1, 10) || ' ' || SUBSTRING(e.PeriodEnd, 12, 8) As TIMESTAMP) ) as DATE ) as visit_end_date,
  DATEADD( 'hour', TO_NUMBER( SUBSTRING(e.PeriodEnd, 20, 3) ), CAST( SUBSTRING(e.PeriodEnd, 1, 10) || ' ' || SUBSTRING(e.PeriodEnd, 12, 8) As TIMESTAMP) ) as visit_end_datetime,
  32817 as visit_type_concept_id,
  pr.ID as provider_id,
  o.ID as care_site_id,
  e.ClassCode as visit_source_value,
  0 as visit_source_concept_id,
  0 as admitted_from_concept_id,
  NULL as admitted_from_source_value,
  0 as discharged_to_concept_id,
  NULL as discharged_to_source_value,
  NULL as preceding_visit_occurrence_id  
FROM
  OMOPSBENC.Encounter e
  LEFT OUTER JOIN OMOPSBPAT.Patient p ON e.SubjectReference = 'Patient/' || p.IdentifierValue  
  LEFT OUTER JOIN OMOPSBPRC.Practitioner pr ON e.ParticipantIndividualReference = 'Practitioner/' || pr.IdentifierValue 
  LEFT OUTER JOIN OMOPSBORG.Organization o ON e.ServiceProviderReference = 'Organization/' || o.IdentifierValue 
  LEFT OUTER JOIN OMOPDTL.F2OMap m ON m.Key = 'EncounterType' AND e.ClassCode = m.Source_Code 

GO

CREATE OR REPLACE VIEW OMOPSTG.v_condition_occurrence AS
SELECT 
  c.ID as condition_occurrence_id,
  p.ID as person_id,
  m1.OMOP_Concept_Id as condition_concept_id,
  TO_DATE(c.RecordedDate, 'YYYY-MM-DD') as condition_start_date,
  TO_TIMESTAMP(c.RecordedDate, 'YYYY-MM-DD') as condition_start_datetime,
  TO_DATE(c.RecordedDate, 'YYYY-MM-DD') as condition_end_date,
  TO_TIMESTAMP(c.RecordedDate, 'YYYY-MM-DD') as condition_end_datetime,
  32817 as condition_type_concept_id,
  m2.OMOP_Concept_Id as condition_status_concept_id,
  NULL as stop_reason,
  NULL as provider_id,
  NULL as visit_occurrence_id,
  NULL as visit_detail_id,
  c.CodeCodingCode as condition_source_value,
  0 as condition_source_concept_id,
  c.ClinicalStatusCodingCode as condition_status_source_value
FROM
  OMOPSBCND.Condition c
  LEFT OUTER JOIN OMOPSBPAT.Patient p ON c.SubjectReference = 'Patient/' || p.IdentifierValue  
  LEFT OUTER JOIN OMOPDTL.F2OMap m1 ON m1."Key" = 'ConditionCode' AND c.CodeCodingCode = m1.Source_Code
  LEFT OUTER JOIN OMOPDTL.F2OMap m2 ON m2."Key" = 'ClinicalStatus' AND c.ClinicalStatusCodingCode = m2.Source_Code

GO

CREATE OR REPLACE VIEW OMOPSTG.v_drug_exposure_oralexternal AS
SELECT 
  (ma.ID * 100) + 1 as drug_exposure_id,
  p.ID as person_id,
  map.OMOP_Concept_Id as drug_concept_id,
  CASE
  	WHEN ma.EffectivePeriodStart IS NOT NULL 
  	  THEN CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectivePeriodStart, 20, 3) ), CAST( SUBSTRING(ma.EffectivePeriodStart, 1, 10) || ' ' || SUBSTRING(ma.EffectivePeriodStart, 12, 8) As TIMESTAMP) ) AS DATE )
  	ELSE
  	  CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(ma.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(ma.EffectiveDateTime, 12, 8) As TIMESTAMP) ) AS DATE ) 
  END as drug_exposure_start_date,
  CASE
  	WHEN ma.EffectivePeriodStart IS NOT NULL
      THEN DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectivePeriodStart, 20, 3) ), CAST( SUBSTRING(ma.EffectivePeriodStart, 1, 10) || ' ' || SUBSTRING(ma.EffectivePeriodStart, 12, 8) As TIMESTAMP) ) 
  	ELSE DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(ma.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(ma.EffectiveDateTime, 12, 8) As TIMESTAMP) ) 
  END as drug_exposure_start_datetime,
  CASE
  	WHEN ma.EffectivePeriodEnd IS NOT NULL 
  	  THEN CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectivePeriodEnd, 20, 3) ), CAST( SUBSTRING(ma.EffectivePeriodEnd, 1, 10) || ' ' || SUBSTRING(ma.EffectivePeriodEnd, 12, 8) As TIMESTAMP) ) AS DATE )
  	ELSE
  	  CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(ma.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(ma.EffectiveDateTime, 12, 8) As TIMESTAMP) ) AS DATE ) 
  END as drug_exposure_end_date,
  CASE
  	WHEN ma.EffectivePeriodEnd IS NOT NULL
      THEN DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectivePeriodEnd, 20, 3) ), CAST( SUBSTRING(ma.EffectivePeriodEnd, 1, 10) || ' ' || SUBSTRING(ma.EffectivePeriodEnd, 12, 8) As TIMESTAMP) ) 
  	ELSE DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(ma.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(ma.EffectiveDateTime, 12, 8) As TIMESTAMP) ) 
  END as drug_exposure_end_datetime,
  NULL as verbatim_end_date,
  32817 as drug_type_concept_id,
  NULL as stop_reason,
  NULL as refills,
  ma.DosageDoseValue as quantity,
  NULL as days_supply,
  NULL as sig,
  0 as route_concept_id,
  NULL as lot_number,
  pr.ID as provider_id,
  NULL as visit_occurrence_id,
  NULL as visit_detail_id,
  ma.MedicationCodeableConceptCodingCode as drug_source_value,
  0 as drug_source_concept_id,
  NULL as route_source_value,
  ma.DosageDoseUnit as dose_unit_source_value
FROM 
  OMOPSBMED.MedicationAdministration ma
  LEFT OUTER JOIN OMOPSBPAT.Patient p ON ma.SubjectReference = 'Patient/' || p.IdentifierValue  
  LEFT OUTER JOIN OMOPSBPRC.Practitioner pr ON ma.PerformerActorReference = 'Practitioner/' || pr.IdentifierValue   
  LEFT OUTER JOIN OMOPDTL.F2OMap map ON map."Key" = 'Drug' AND map.Source_Code = ma.MedicationCodeableConceptCodingCode
WHERE 
  ma.MetaProfile = 'http://jpfhir.jp/fhir/core/StructureDefinition/JP_MedicationAdministration'
  AND ma.Status IN ('completed', 'in-progress', 'on-hold')

GO

CREATE OR REPLACE VIEW OMOPSTG.v_drug_exposure_injection AS
SELECT 
  cmi.MedicationAdministration * 100 + cmi.ContainedMedicationIngredientsNumber as drug_exposure_id,
  p.ID as person_id,
  map.OMOP_Concept_Id as drug_concept_id,
  CASE
  	WHEN ma.EffectivePeriodStart IS NOT NULL 
  	  THEN CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectivePeriodStart, 20, 3) ), CAST( SUBSTRING(ma.EffectivePeriodStart, 1, 10) || ' ' || SUBSTRING(ma.EffectivePeriodStart, 12, 8) As TIMESTAMP) ) AS DATE )
  	ELSE
  	  CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(ma.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(ma.EffectiveDateTime, 12, 8) As TIMESTAMP) ) AS DATE ) 
  END as drug_exposure_start_date,
  CASE
  	WHEN ma.EffectivePeriodStart IS NOT NULL
      THEN DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectivePeriodStart, 20, 3) ), CAST( SUBSTRING(ma.EffectivePeriodStart, 1, 10) || ' ' || SUBSTRING(ma.EffectivePeriodStart, 12, 8) As TIMESTAMP) ) 
  	ELSE DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(ma.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(ma.EffectiveDateTime, 12, 8) As TIMESTAMP) ) 
  END as drug_exposure_start_datetime,
  CASE
  	WHEN ma.EffectivePeriodEnd IS NOT NULL 
  	  THEN CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectivePeriodEnd, 20, 3) ), CAST( SUBSTRING(ma.EffectivePeriodEnd, 1, 10) || ' ' || SUBSTRING(ma.EffectivePeriodEnd, 12, 8) As TIMESTAMP) ) AS DATE )
  	ELSE
  	  CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(ma.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(ma.EffectiveDateTime, 12, 8) As TIMESTAMP) ) AS DATE ) 
  END as drug_exposure_end_date,
  CASE
  	WHEN ma.EffectivePeriodStart IS NOT NULL
      THEN DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectivePeriodEnd, 20, 3) ), CAST( SUBSTRING(ma.EffectivePeriodEnd, 1, 10) || ' ' || SUBSTRING(ma.EffectivePeriodEnd, 12, 8) As TIMESTAMP) ) 
  	ELSE DATEADD( 'hour', TO_NUMBER( SUBSTRING(ma.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(ma.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(ma.EffectiveDateTime, 12, 8) As TIMESTAMP) ) 
  END as drug_exposure_end_datetime,
  NULL as verbatim_end_date,
  32817 as drug_type_concept_id,
  NULL as stop_reason,
  NULL as refills,
  ma.DosageDoseValue as quantity,
  NULL as days_supply,
  NULL as sig,
  0 as route_concept_id,
  NULL as lot_number,
  pr.ID as provider_id,
  NULL as visit_occurrence_id,
  NULL as visit_detail_id,
  cmi.ItemCodeableConceptCodingCode as drug_source_value,
  0 as drug_source_concept_id,
  NULL as route_source_value,
  ma.DosageDoseUnit as dose_unit_source_value
FROM 
  OMOPSBMED.MedicationAdministration ma
  LEFT OUTER JOIN OMOPSBPAT.Patient p ON ma.SubjectReference = 'Patient/' || p.IdentifierValue  
  LEFT OUTER JOIN OMOPSBPRC.Practitioner pr ON ma.PerformerActorReference = 'Practitioner/' || pr.IdentifierValue   
  LEFT OUTER JOIN OMOPSBMED.ContainedMedicationIngredients cmi ON cmi.MedicationAdministration = ma.ID
  LEFT OUTER JOIN OMOPDTL.F2OMap map ON map."Key" = 'Drug' AND cmi.ItemCodeableConceptCodingCode = map.Source_Code 
WHERE 
  ma.MetaProfile = 'http://jpfhir.jp/fhir/core/StructureDefinition/JP_MedicationAdministration_Injection'
  AND ma.Status IN ('completed', 'in-progress', 'on-hold')

GO

CREATE OR REPLACE VIEW OMOPSTG.v_procedure_occurrence AS
SELECT 
  pcd.ID as procedure_occurrence_id,
  pat.ID as person_id,
  map1.OMOP_Concept_Id as procedure_concept_id,
  TO_DATE( pcd.PerformedDateTime, 'YYYY-MM-DD' ) as procedure_date,
  TO_TIMESTAMP( pcd.PerformedDateTime, 'YYYY-MM-DD' ) as procedure_datetime,
  NULL as procedure_end_date,
  NULL as procedure_end_datetime,
  map2.OMOP_Concept_Id as procedure_type_concept_id,
  0 as modifier_concept_id,
  NULL as quantity,
  NULL as provider_id,
  NULL as visit_occurrence_id,
  NULL as visit_detail_id,
  pcd.CodeCodingCode as procedure_source_value,
  0 as procedure_source_concept_id,
  NULL as modifier_source_value
FROM 
  OMOPSBPCD."Procedure" pcd
  INNER JOIN OMOPSBPCD.CodeCodings cc ON pcd.ID = cc."Procedure" AND cc.System = 'http://jpfhir.jp/fhir/core/CodeSystem/JP_ProcedureCodesMedical_CS'
  LEFT OUTER JOIN OMOPSBPAT.Patient pat ON pcd.SubjectReference = 'Patient/' || pat.IdentifierValue
  LEFT OUTER JOIN OMOPDTL.F2OMap map1 ON map1."Key" = 'Procedure' AND map1.Source_Code = cc.Code 
  LEFT OUTER JOIN OMOPDTL.F2OMap map2 ON map2."Key" = 'ProcedureCategory' AND map2.Source_Code = pcd.CategoryCodingCode 

GO

CREATE OR REPLACE VIEW OMOPSTG.v_measurement_bodymeasurement AS
SELECT 
  obs.ID as measurement_id,
  pat.ID as person_id,
  map1.OMOP_Concept_Id as measurement_concept_id,
  CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(obs.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(obs.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(obs.EffectiveDateTime, 12, 8) As TIMESTAMP) ) AS DATE) as measurement_date,
  DATEADD( 'hour', TO_NUMBER( SUBSTRING(obs.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(obs.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(obs.EffectiveDateTime, 12, 8) As TIMESTAMP) ) as measurement_datetime,
  TO_CHAR( DATEADD( 'hour', TO_NUMBER( SUBSTRING(obs.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(obs.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(obs.EffectiveDateTime, 12, 8) As TIMESTAMP) ), 'HH24:MI') as measurement_time,
  32817 as measurement_type_concept_id,
  0 as operator_concept_id,
  obs.ValueQuantityValue as value_as_number,
  0 as value_as_concept_id,
  map2.OMOP_Concept_Id as unit_concept_id,
  obs.ReferenceRangeLowValue as range_low,
  obs.ReferenceRangeHighValue as range_high,
  prc.ID as provider_id,
  enc.ID as visit_occurrence_id,
  NULL as visit_detail_id,
  cc.Code as measurement_source_value,
  0 as measurement_source_concept_id,
  obs.ValueQuantityUnit as unit_source_value,
  0 as unit_source_concept_id,
  obs.ValueQuantityValue as value_source_value,
  NULL as measurement_event_id,
  0 as meas_event_field_concept_id
FROM 
  OMOPSBOBS.Observation obs
  INNER JOIN OMOPSBOBS.CodeCodings cc ON obs.ID = cc.Observation AND cc.System = 'http://jpfhir.jp/fhir/core/CodeSystem/JP_ObservationBodyMeasurementCode_CS'   
  LEFT OUTER JOIN OMOPDTL.F2OMap map1 ON map1."Key" = 'BodyMeasurement' AND map1.Source_Code = cc.Code
  LEFT OUTER JOIN OMOPDTL.F2OMap map2 ON map1."Key" = 'Unit' AND map2.Source_Code = obs.ValueQuantityUnit
  LEFT OUTER JOIN OMOPSBPAT.Patient pat ON obs.SubjectReference = 'Patient/' || pat.IdentifierValue  
  LEFT OUTER JOIN OMOPSBPRC.Practitioner prc ON obs.PerformerReference = 'Practitioner/' || prc.IdentifierValue 
  LEFT OUTER JOIN OMOPSBENC.Encounter enc ON obs.EncounterReference = 'Encounter/' || enc.IdentifierValue
WHERE 
  obs.MetaProfile = 'http://jpfhir.jp/fhir/core/StructureDefinition/JP_Observation_BodyMeasurement'

GO

CREATE OR REPLACE VIEW OMOPSTG.v_measurement_labresult AS
SELECT 
  obs.ID as measurement_id,
  pat.ID as person_id,
  cc.Code as measurement_concept_id,
  CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(obs.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(obs.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(obs.EffectiveDateTime, 12, 8) As TIMESTAMP) ) AS DATE) as measurement_date,
  DATEADD( 'hour', TO_NUMBER( SUBSTRING(obs.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(obs.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(obs.EffectiveDateTime, 12, 8) As TIMESTAMP) ) as measurement_datetime,
  TO_CHAR( DATEADD( 'hour', TO_NUMBER( SUBSTRING(obs.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(obs.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(obs.EffectiveDateTime, 12, 8) As TIMESTAMP) ), 'HH24:MI') as measurement_time,
  32817 as measurement_type_concept_id,
  0 as operator_concept_id,
  obs.ValueQuantityValue as value_as_number,
  0 as value_as_concept_id,
  map2.OMOP_Concept_Id as unit_concept_id,
  obs.ReferenceRangeLowValue as range_low,
  obs.ReferenceRangeHighValue as range_high,
  prc.ID as provider_id,
  enc.ID as visit_occurrence_id,
  NULL as visit_detail_id,
  cc.Code as measurement_source_value,
  0 as measurement_source_concept_id,
  obs.ValueQuantityUnit as unit_source_value,
  0 as unit_source_concept_id,
  obs.ValueQuantityValue as value_source_value,
  NULL as measurement_event_id,
  0 as meas_event_field_concept_id
FROM 
  OMOPSBOBS.Observation obs
  INNER JOIN OMOPSBOBS.CodeCodings cc ON obs.ID = cc.Observation AND cc.System = 'urn:oid:1.2.392.200119.4.504'  
  LEFT OUTER JOIN OMOPDTL.F2OMap map1 ON map1."Key" = 'LabResult' AND map1.Source_Code = cc.Code
  LEFT OUTER JOIN OMOPDTL.F2OMap map2 ON map1."Key" = 'Unit' AND map2.Source_Code = obs.ValueQuantityUnit
  LEFT OUTER JOIN OMOPSBPAT.Patient pat ON obs.SubjectReference = 'Patient/' || pat.IdentifierValue  
  LEFT OUTER JOIN OMOPSBPRC.Practitioner prc ON obs.PerformerReference = 'Practitioner/' || prc.IdentifierValue 
  LEFT OUTER JOIN OMOPSBENC.Encounter enc ON obs.EncounterReference = 'Encounter/' || enc.IdentifierValue
WHERE 
  obs.MetaProfile = 'http://jpfhir.jp/fhir/core/StructureDefinition/JP_Observation_LabResult'

GO

CREATE OR REPLACE VIEW OMOPSTG.v_measurement_vitalsigns AS
SELECT 
  obs.ID as measurement_id,
  pat.ID as person_id,
  map1.OMOP_Concept_Id as measurement_concept_id,
  CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(obs.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(obs.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(obs.EffectiveDateTime, 12, 8) As TIMESTAMP) ) AS DATE) as measurement_date,
  DATEADD( 'hour', TO_NUMBER( SUBSTRING(obs.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(obs.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(obs.EffectiveDateTime, 12, 8) As TIMESTAMP) ) as measurement_datetime,
  TO_CHAR( DATEADD( 'hour', TO_NUMBER( SUBSTRING(obs.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(obs.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(obs.EffectiveDateTime, 12, 8) As TIMESTAMP) ), 'HH24:MI') as measurement_time,
  32817 as measurement_type_concept_id,
  0 as operator_concept_id,
  obs.ValueQuantityValue as value_as_number,
  0 as value_as_concept_id,
  map2.OMOP_Concept_Id as unit_concept_id,
  obs.ReferenceRangeLowValue as range_low,
  obs.ReferenceRangeHighValue as range_high,
  prc.ID as provider_id,
  enc.ID as visit_occurrence_id,
  NULL as visit_detail_id,
  cc.Code as measurement_source_value,
  0 as measurement_source_concept_id,
  obs.ValueQuantityUnit as unit_source_value,
  0 as unit_source_concept_id,
  obs.ValueQuantityValue as value_source_value,
  NULL as measurement_event_id,
  0 as meas_event_field_concept_id
FROM 
  OMOPSBOBS.Observation obs
  INNER JOIN OMOPSBOBS.CodeCodings cc ON obs.ID = cc.Observation AND cc.System = 'urn:oid:1.2.392.200119.4.804'
  LEFT OUTER JOIN OMOPDTL.F2OMap map1 ON map1."Key" = 'VitalSign' AND map1.Source_Code = cc.Code
  LEFT OUTER JOIN OMOPDTL.F2OMap map2 ON map1."Key" = 'Unit' AND map2.Source_Code = obs.ValueQuantityUnit
  LEFT OUTER JOIN OMOPSBPAT.Patient pat ON obs.SubjectReference = 'Patient/' || pat.IdentifierValue  
  LEFT OUTER JOIN OMOPSBPRC.Practitioner prc ON obs.PerformerReference = 'Practitioner/' || prc.IdentifierValue 
  LEFT OUTER JOIN OMOPSBENC.Encounter enc ON obs.EncounterReference = 'Encounter/' || enc.IdentifierValue
WHERE 
  obs.MetaProfile = 'http://jpfhir.jp/fhir/core/StructureDefinition/JP_Observation_VitalSigns'

GO

CREATE OR REPLACE VIEW OMOPSTG.v_observation_socialhistory AS 
SELECT 
  obs.ID as observation_id,
  pat.ID as person_id,
  map1.OMOP_Concept_Id as observation_concept_id,
  CAST( DATEADD( 'hour', TO_NUMBER( SUBSTRING(obs.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(obs.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(obs.EffectiveDateTime, 12, 8) As TIMESTAMP) ) AS DATE) as observation_date,
  DATEADD( 'hour', TO_NUMBER( SUBSTRING(obs.EffectiveDateTime, 20, 3) ), CAST( SUBSTRING(obs.EffectiveDateTime, 1, 10) || ' ' || SUBSTRING(obs.EffectiveDateTime, 12, 8) As TIMESTAMP) ) as observation_datetime,
  32817 as observation_type_concept_id,
  obs.ValueQuantityValue as value_as_number,
  NULL as value_as_string,
  0 as value_as_concept_id,
  0 as qualifier_concept_id,
  map2.OMOP_Concept_Id as unit_concept_id,
  prc.ID as provider_id,
  enc.ID as visit_occurrence_id,
  NULL as visit_detail_id,
  cc.Code as observation_source_value,
  0 as observation_source_concept_id,
  obs.ValueQuantityUnit as unit_source_value,
  NULL as qualifier_source_value,
  obs.ValueQuantityValue as value_source_value,
  NULL as observation_event_id,
  0 as obs_event_field_concept_id
FROM 
  OMOPSBOBS.Observation obs
  INNER JOIN OMOPSBOBS.CodeCodings cc ON obs.ID = cc.Observation AND cc.System = 'http://jpfhir.jp/fhir/core/CodeSystem/JP_ObservationSocialHistoryCode_CS'
  LEFT OUTER JOIN OMOPDTL.F2OMap map1 ON map1."Key" = 'SocialHistory' AND map1.Source_Code = cc.Code
  LEFT OUTER JOIN OMOPDTL.F2OMap map2 ON map1."Key" = 'Unit' AND map2.Source_Code = obs.ValueQuantityUnit
  LEFT OUTER JOIN OMOPSBPAT.Patient pat ON obs.SubjectReference = 'Patient/' || pat.IdentifierValue  
  LEFT OUTER JOIN OMOPSBPRC.Practitioner prc ON obs.PerformerReference = 'Practitioner/' || prc.IdentifierValue 
  LEFT OUTER JOIN OMOPSBENC.Encounter enc ON obs.EncounterReference = 'Encounter/' || enc.IdentifierValue
WHERE 
  obs.MetaProfile = 'http://jpfhir.jp/fhir/core/StructureDefinition/JP_Observation_SocialHistory'

GO

CREATE OR REPLACE VIEW OMOPSTG.v_drug_exposure AS
SELECT
  drug_exposure_id,
  person_id,
  drug_concept_id,
  drug_exposure_start_date,
  drug_exposure_start_datetime,
  drug_exposure_end_date,
  drug_exposure_end_datetime,
  verbatim_end_date,
  drug_type_concept_id,
  stop_reason,
  refills,
  quantity,
  days_supply,
  sig,
  route_concept_id,
  lot_number,
  provider_id,
  visit_occurrence_id,
  visit_detail_id,
  drug_source_value,
  drug_source_concept_id,
  route_source_value,
  dose_unit_source_value
FROM 
  OMOPSTG.v_drug_exposure_oralexternal 
UNION ALL
SELECT
  drug_exposure_id,
  person_id,
  drug_concept_id,
  drug_exposure_start_date,
  drug_exposure_start_datetime,
  drug_exposure_end_date,
  drug_exposure_end_datetime,
  verbatim_end_date,
  drug_type_concept_id,
  stop_reason,
  refills,
  quantity,
  days_supply,
  sig,
  route_concept_id,
  lot_number,
  provider_id,
  visit_occurrence_id,
  visit_detail_id,
  drug_source_value,
  drug_source_concept_id,
  route_source_value,
  dose_unit_source_value
FROM 
  OMOPSTG.v_drug_exposure_injection 

GO

CREATE OR REPLACE VIEW OMOPSTG.v_measurement AS
SELECT 
  measurement_id,
  person_id,
  measurement_concept_id,
  measurement_date,
  measurement_datetime,
  measurement_time,
  measurement_type_concept_id,
  operator_concept_id,
  value_as_number,
  value_as_concept_id,
  unit_concept_id,
  range_low,
  range_high,
  provider_id,
  visit_occurrence_id,
  visit_detail_id,
  measurement_source_value,
  measurement_source_concept_id,
  unit_source_value,
  unit_source_concept_id,
  value_source_value,
  measurement_event_id,
  meas_event_field_concept_id
FROM
  OMOPSTG.v_measurement_bodymeasurement 
UNION ALL
SELECT 
  measurement_id,
  person_id,
  measurement_concept_id,
  measurement_date,
  measurement_datetime,
  measurement_time,
  measurement_type_concept_id,
  operator_concept_id,
  value_as_number,
  value_as_concept_id,
  unit_concept_id,
  range_low,
  range_high,
  provider_id,
  visit_occurrence_id,
  visit_detail_id,
  measurement_source_value,
  measurement_source_concept_id,
  unit_source_value,
  unit_source_concept_id,
  value_source_value,
  measurement_event_id,
  meas_event_field_concept_id
FROM
  OMOPSTG.v_measurement_labresult 
UNION ALL
SELECT 
  measurement_id,
  person_id,
  measurement_concept_id,
  measurement_date,
  measurement_datetime,
  measurement_time,
  measurement_type_concept_id,
  operator_concept_id,
  value_as_number,
  value_as_concept_id,
  unit_concept_id,
  range_low,
  range_high,
  provider_id,
  visit_occurrence_id,
  visit_detail_id,
  measurement_source_value,
  measurement_source_concept_id,
  unit_source_value,
  unit_source_concept_id,
  value_source_value,
  measurement_event_id,
  meas_event_field_concept_id
FROM
  OMOPSTG.v_measurement_vitalsigns 

GO

CREATE OR REPLACE VIEW OMOPSTG.v_observation AS 
SELECT 
  observation_id,
  person_id,
  observation_concept_id,
  observation_date,
  observation_datetime,
  observation_type_concept_id,
  value_as_number,
  value_as_string,
  value_as_concept_id,
  qualifier_concept_id,
  unit_concept_id,
  provider_id,
  visit_occurrence_id,
  visit_detail_id,
  observation_source_value,
  observation_source_concept_id,
  unit_source_value,
  qualifier_source_value,
  value_source_value,
  observation_event_id,
  obs_event_field_concept_id
FROM 
OMOPSTG.v_observation_socialhistory

GO
