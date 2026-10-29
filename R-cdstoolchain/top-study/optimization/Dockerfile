# Same model package and runtime as the reference run.
FROM ghcr.io/onto-med/top-interpolar-algorithms:1.1.1@sha256:37f1c73baedbd4962c61b70107fcef061542e8f8405ad6d1e5fbf3d4cc29a8a7 AS original

FROM eclipse-temurin:25-jdk AS compiler
# Fix the reviewed PR revision so the comparison cannot change between site runs.
ARG OPTIMIZATION_COMMIT=e7d5f286b5a7f401a97d8e93fbd022f24000f4f3
WORKDIR /build
COPY PatchJar.java ./PatchJar.java
COPY --from=original /opt/app/top-phenotypic-query.jar ./top-phenotypic-query.jar
ADD https://raw.githubusercontent.com/astruebi/top-phenotypic-query/${OPTIMIZATION_COMMIT}/src/main/java/care/smith/top/top_phenotypic_query/util/Phenotypes.java ./Phenotypes.java
RUN printf 'optimization_pr=https://github.com/Onto-Med/top-phenotypic-query/pull/158\noptimization_commit=%s\n' "$OPTIMIZATION_COMMIT" > optimization.txt \
    && printf 'original_jar_sha256=' >> optimization.txt \
    && sha256sum top-phenotypic-query.jar | cut -d ' ' -f 1 >> optimization.txt \
    && javac -version >> optimization.txt 2>&1 \
    && javac --release 25 -cp top-phenotypic-query.jar -d classes Phenotypes.java \
    && java PatchJar.java top-phenotypic-query.jar classes \
    && printf 'optimized_jar_sha256=' >> optimization.txt \
    && sha256sum top-phenotypic-query.jar | cut -d ' ' -f 1 >> optimization.txt

FROM original
COPY --from=compiler /build/top-phenotypic-query.jar /opt/app/top-phenotypic-query.jar
COPY --from=compiler /build/optimization.txt /opt/app/optimization.txt
