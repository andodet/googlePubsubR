# googlePubsubR 0.0.3

* Add helper methods (`ps_project_set/get`) to switch between GCP projects (thanks MarkEdmonson1234,
 #13).
* Quieter warnings when env variables are not set (#13)
* Deleted extra `name` argument from `topics_create` (thanks muschellij2)

# googlePubsubR 0.0.2

* Add helpers to encode/decode messages: `msg_encode`, `msg_decode`.
* `pubsub_auth` now prompts the correct package name (fixes #6)

# googlePubsubR 0.0.1

* Initial version
