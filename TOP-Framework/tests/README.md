# TOP analysis tests

Run the following block in Bash from the repository root. It requires Docker,
the built `interpolar-r-env:latest` image, and a local R installation with `etlutils`.
The integration test creates its own database with synthetic data.

```bash
set -euo pipefail
trap 'echo "TOP test failed; see the output above." >&2' ERR
bash TOP-Framework/tests/check-image-refresh.sh
Rscript TOP-Framework/tests/check-output.R
bash TOP-Framework/tests/integration.sh
printf 'PASS: all TOP checks completed.\n'
```

## Synthetic integration test

The TOP image is defined in [`image.txt`](../image.txt); the runner refreshes `latest` before each run.
The test uses the existing R runtime and the current TOP image with two small
model fixtures and the original anaemia and encounter models. It verifies five
selected hospital cases from nine candidates,
including a prior hospital admission, a first ward contact before the study,
start/end boundaries, duplicate contacts, separate ward periods, completed
contacts and other cases of the same patient.

The association regression test compares the complete preparation counts with
`legacy-health.sql`, including missing encounters, missing dates/references,
malformed references, wrong encounter types, unknown/null wards, duplicate
contacts and duplicate hospital cases. Repeated imports retain the original
diagnostic counts; distinct encounter/ward pairs define study eligibility.

The ICD fixture derives its single phenotype from the bundled delirium model,
retains only F05.- without pre-expanded child codes and adds a boolean wrapper.
Thus F05.1 matches verify the ICD prefix matching supplied by TOP. The lab fixture uses
the bundled hypokalemia Algorithm 1 A. A missing observation relation then
verifies fail-fast behavior, a failed summary, and credential cleanup.
Interruptions during TOP execution and R preparation verify cleanup and status reporting.

Seven missing-contact rows (including duplicates and a null ID) are logged and
ignored in the end-to-end run. A separate missing start date still blocks TOP.

The public `outputGlobal/top-study/TOP_Report_YYYY-MM-DD_HH-MM-SS.txt` includes aggregate results
and separate diagnostic counts. Tests cover success, preparation/query failure
and interruptions, and check that credentials and raw logs are not included.

The full TOP ZIPs stay in `outputLocal/top-study/results/`, including metadata. Tests
inspect all three CSV members, exact case IDs and phenotype/metadata consistency.
The public folder contains only the aggregate report. `check-catalog.sh` checks
the model names, phenotype IDs and titles of all executable entries in the current image.

The independent audit groups first ward contacts separately from the adapter's
window query. Synthetic haemoglobin rows include duplicated measurements,
failed unit conversion, unknown sex, findings before IP contact and after study
end, and a positive non-study case. Laboratory algorithms are checked against
local TOP ZIPs. Exclusion diagnoses are counted without changing TOP selection.
A failed audit has its own run phase and retains completed aggregate sections.

The audit regression deliberately swaps one positive case for another while
retaining equal totals, checks missing laboratory/patient data and reads all
original model files from the current image. Model limits are saved locally in `model-limits.tsv`.

Laboratory summaries group by LOINC, actual unit and status, listing the models
jointly. Counts refer to FHIR Observations; minimum, median and maximum use numeric
values. Regression tests cover unequal flattened multiplicities, distinct resources
with equal values, absent values, failed/unknown statuses and ambiguous identities.
The TOP observation query preserves distinct resources and excludes unsuccessful
statuses; the generated adapter retains this query and adds the study population filter. Only aggregate clinical summaries appear in the public report.

The integration test also verifies that the previous run is retained in timestamped
folders and that a concurrent start is rejected while the active run keeps its lock.
The recorded image digest must match the image selected for the run, and the
framework version is read from that image. Original TOP query fragments and
restrictions are checked against the generated adapter.

## Focused startup and output checks

- `check-output.R` verifies creation of the current output folders, preservation of
  existing run contents, rejection of timestamp collisions before rotation, and
  the configured retention limit.
- `check-image-refresh.sh` simulates a failed image download. It verifies that the
  runner requests `latest`, exits with the download failure, preserves the previous
  outputs, and releases the startup lock.
