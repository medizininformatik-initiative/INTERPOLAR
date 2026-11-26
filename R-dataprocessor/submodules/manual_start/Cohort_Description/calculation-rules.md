# Cohort calculation rules

These rules describe the current calculation for the sections listed below.
The working workbook records the rules beside the corresponding rows.
Apply each rule to the selected station, study, FAS and subgroup.

## Medication analyses

A completed medication analysis (MedA) must have REDCap status `Complete`
and a recorded date and time within the hospital case. The first MedA in
this section means the earliest completed MedA of that case.

| Measure | Reference population and N | Numerator or case-level value | Missing information |
|---|---|---|---|
| Cases with a first completed MedA | All cases in the selected group. | Count cases whose first completed MedA matches the location in the row. | Zero. No matching MedA counts as no. |
| Number of completed MedAs | All cases in the selected group. | Count distinct completed MedAs per case in the location in the row. | Zero. No matching MedA counts as zero. |
| Days until the first completed MedA | Cases with a calculable interval. | Days from hospital admission or first known IP entry to the first completed MedA. The interval from IP entry can be negative. | Cases without a dated completed MedA in the hospital case or without the admission time named in the row. |
| Days until the first completed MedA on the first INTERPOLAR ward | Cases with a calculable interval whose first completed MedA of the hospital case falls within the first known IP stay. | Days from the admission point named in the row to the first completed MedA of the hospital case. | Cases without a dated completed MedA, with their first completed MedA outside the first known IP stay, or without the admission time named in the row. |

A later known IP stay includes a return to the same ward. A MedA outside
known IP stays after the first IP stay has no matching known IP interval.

## Multiple hospital admissions

N includes all cases in the selected group. For each case, count the
patient's other available hospital admissions up to and including the
first known IP entry. No other recorded admission counts as zero.
Missing Information is zero.
