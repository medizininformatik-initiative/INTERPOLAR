# Synthetic integration test

Run `bash R-cdstoolchain/top-study/tests/integration.sh` from the checkout.
The TOP image is defined once in `../image.txt`; rerun this test after updating it.
The test uses the existing R runtime and the pinned TOP image with two small
model fixtures. It verifies five selected hospital cases from nine candidates,
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
Thus F05.1 matches demonstrate the adapter prefix change. The lab fixture uses
the bundled hypokalemia Algorithm 1 A. A missing observation relation then
verifies fail-fast behavior, a failed summary, and credential cleanup.
Interruptions during TOP execution and R preparation verify cleanup and status reporting.

Seven missing-contact rows (including duplicates and a null ID) are logged and
ignored in the end-to-end run. A separate missing start date still blocks TOP.

The public `outputGlobal/top-study/<run>/report.txt` includes aggregate results
and separate diagnostic counts. Tests cover success, preparation/query failure
and interruptions, and check that credentials and raw logs are not included.

The full TOP ZIPs are exported to `outputGlobal/.../results/`. Tests inspect all
three CSV members, exact case IDs and phenotype/metadata consistency. The report
remains aggregate-only. `check-catalog.sh` checks all 73 entries in the pinned
image and the explicit classification of the two intermediate criteria. Revisit
these reviewed IDs in `algorithm-list.jq` when updating the TOP models.
