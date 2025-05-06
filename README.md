# dlrm-data-ingest-project-template
A template that can be used to accelerate customising the DLRM data Ingest landing zones to suit a given project.

## Getting Started

This template is designed to be used with the DLRM data ingest project. It provides a starting point for layering project specific customisations on top of the existing DLRM Data Ingest Landing Zones.

1) Click the "Use this template" button to create a new repository based on this template.
2) Create a new pipeline in Azure DevOps pointing to the `azure-pupelines.yaml` file in the root of the repository.
3) Clone the repository to your local machine/normal development environment.
4) Make any changes to the `azure-pipelines.yaml` file to suit your project. This may include:
   - Changing the name of the pipeline
   - Changing the branch that the pipeline runs on
   - Adding or removing steps from the pipeline
5) Rename instances of `project` with your project name.
6) Update the `landing_zones` variable in the `tfvars` files to point to your own Landing Zone(s) deployed via [dlrm-data-ingest-infra](https://github.com/hmcts/dlrm-data-ingest-infra).
7) Raise a PR with your changes, the pipeline should be triggered automatically. You will need to approve the use of the service connections on first run.