## Resubmission

This is a resubmission. In this version I have:

* Add helper methods (`ps_project_set/get`) to switch between GCP projects (#13)
* Quieter warnings when env variables are not set (#13)
* Deleted extra `name` argument from `topics_create` (thanks muschellij2)

## Test environments

* Ubuntu 20.04 (on Github Actions), r-devel
* Ubuntu 20.04 (on Github Actions), R 4.1.2
* Ubuntu 20.04 (on Github Actions), R 4.0.5
* Windows, R 4.1.2
* Solaris (rhub)

## R CMD check results

0 errors | 0 warnings | 0 note
