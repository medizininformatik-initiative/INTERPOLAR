
#Set SEP and BRACKETS
BRACKETS <- c('[', ']')
SEP      <- ' ~ '

#Create Table-Descriptions and Designs for relevant resources
TABLE_DESCRIPTION <- list(
  'Encounter' = fhir_table_description(
    resource = 'Encounter',
    cols = c(
      Enc.Enc.ID                 = 'id',
      Enc.Ext.ID                 = 'identifier/value',
      Enc.Pat.ID                 = 'subject/reference',
      Enc.Con.ID                 = 'diagnosis/condition/reference',
      Enc.PartOf.ID              = 'partOf/reference',
      Enc.Class.Code             = 'class/code',
      Enc.Class.System           = 'class/system',
      Enc.Class.Display          = 'class/display',
      Enc.Hospitalization.Code   = 'hospitalization/admitSource/coding/code',
      Enc.ServiceType.System     = 'serviceType/coding/system',
      Enc.Service.Code           = 'serviceType/coding/code',
      Enc.Service.Display        = 'serviceType/coding/display',
      Enc.Period.Start           = 'period/start',
      Enc.Period.End             = 'period/end',
      Enc.Type.System            = 'type/coding/system',
      Enc.Type.Code              = 'type/coding/code',
      Enc.ServiceProvider.System = 'serviceProvider/identifier/system',
      Enc.ServiceProvider.Value  = 'serviceProvider/identifier/value'
    ),
    style    = fhir_style(
      sep      = SEP,
      brackets = NULL
    )
  ),

  'Patient' = fhir_table_description(
    resource = 'Patient',
    cols     = c(
      Pat.Pat.ID = 'id',
      Pat.Ext.ID = 'identifier/value',
      Pat.DOB    = 'birthDate',
      Pat.Gender = 'gender'
    ),
    style    = fhir_style(
      sep      = SEP,
      brackets = NULL
    )
  ),

  'Condition' = fhir_table_description(
    resource = 'Condition',
    cols     = c(
      Con.Con.ID      = 'id',
      Con.Enc.ID      = 'encounter/reference',
      Con.Pat.ID      = 'subject/reference',
      Con.Code.System = 'code/coding/system',
      Con.Code.Code   = 'code/coding/code',
      Con.Name        = 'code/text',
      Con.Time        = 'recordedDate'
    ),
    style    = fhir_style(
      sep      = SEP,
      brackets = NULL
    )
  ),

  'Medication' = fhir_table_description(
    resource = 'Medication',
    cols     = c(
      Med.Med.ID                   = 'id',
      Med.Code                     = 'code/coding/code',
      Med.Display                  = 'code/coding/display',
      Med.Name                     = 'code/text',
      Med.System                   = 'code/coding/system',
      Med.Version                  = 'code/coding/version',
      # TODO: Ingredient handle requires a major revision
      #Ingredient.display           = 'ingredient/itemCodeableConcept/display',
      #Ingredient.code              = 'ingredient/itemCodeableConcept/coding/code',
      #Ingredient.system            = 'ingredient/itemCodeableConcept/coding/system',
      Ingredient.numerator.value   = 'ingredient/strength/numerator/value',
      Ingredient.numerator.code    = 'ingredient/strength/numerator/code',
      Ingredient.numerator.unit    = 'ingredient/strength/numerator/unit',
      Ingredient.denominator.value = 'ingredient/strength/denominator/value',
      Ingredient.denominator.code  = 'ingredient/strength/denominator/code',
      Ingredient.denominator.unit  = 'ingredient/strength/denominator/unit'
    ),
    style    = fhir_style(
      sep      = SEP,
      brackets = NULL
    )
  ),

  'MedicationAdministration' = fhir_table_description(
    resource = 'MedicationAdministration',
    cols     = c(
      MedAdm.MedAdm.ID       = 'id',
      MedAdm.Med.ID          = 'medicationReference/reference',
      MedAdm.Pat.ID          = 'subject/reference',
      MedAdm.Enc.ID          = 'context/reference',
      MedAdm.Start           = 'effectivePeriod/start',
      MedAdm.End             = 'effectivePeriod/end',
      MedAdm.Time            = 'effectiveDateTime',
      MedAdm.Dosage.Quantity = 'dosage/dose/value',
      MedAdm.Dosage.Code     = 'dosage/dose/code',
      MedAdm.Dosage.Unit     = 'dosage/dose/unit'
    ),
    style    = fhir_style(
      sep      = SEP,
      brackets = NULL
    )
  ),

  'MedicationStatement' = fhir_table_description(
    resource = 'MedicationStatement',
    cols     = c(
      MedStat.MedStat.ID      = 'id',
      MedStat.Med.ID          = 'medicationReference/reference',
      MedStat.Pat.ID          = 'subject/reference',
      MedStat.Enc.ID          = 'context/reference',
      MedStat.Start           = 'effectivePeriod/start',
      MedStat.End             = 'effectivePeriod/end',
      MedStat.Time            = 'effectiveDateTime',
      MedStat.Dosage.Quantity = 'dosage/doseAndRate/doseQuantity/value',
      MedStat.Dosage.Code     = 'dosage/doseAndRate/doseQuantity/code',
      MedStat.Dosage.Unit     = 'dosage/doseAndRate/doseQuantity/unit'
      #MedStat.Dosage.Unit     = 'dosage/dose/unit'
    ),
    style    = fhir_style(
      sep      = SEP,
      brackets = NULL
    )
  ),

  "Observation" = fhir_table_description(
    resource = "Observation",
    cols = c(
      Obs.Obs.ID              = "id",
      Obs.Pat.ID              = "subject/reference",
      Obs.Enc.ID              = "encounter/reference",
      Obs.Ext.ID              = 'identifier/value',
      Obs.Code.System         = "code/coding/system",
      Obs.Code.Code           = "code/coding/code",
      Obs.Name                = "code/text",
      Obs.Time                = "effectiveDateTime",
      Obs.ValueQuantity.Value = "valueQuantity/value",
      Obs.ValueQuantity.Code  = "valueQuantity/code",
      Obs.ValueQuantity.Unit  = "valueQuantity/unit"

    ),
    style    = fhir_style(
      sep      = SEP,
      brackets = NULL
    )
  )
)
