# Synthetic integration test

Run `bash R-cdstoolchain/top-study/tests/integration.sh` from the checkout.
The TOP image is defined once in `../image.txt`; rerun this test after updating it.
The test uses the existing R runtime and the pinned TOP image with two small
model fixtures. It verifies five selected hospital cases from nine candidates,
including a prior hospital admission, a first ward contact before the study,
start/end boundaries, duplicate contacts, separate ward periods, completed
contacts and other cases of the same patient.

The ICD fixture derives its single phenotype from the bundled delirium model,
retains only F05.- without pre-expanded child codes and adds a boolean wrapper.
Thus F05.1 matches demonstrate the adapter prefix change. The lab fixture uses
the bundled hypokalemia Algorithm 1 A. A missing observation relation then
verifies fail-fast behavior, a failed summary, and credential cleanup.
Interruptions during TOP execution and R preparation verify cleanup and status reporting.
