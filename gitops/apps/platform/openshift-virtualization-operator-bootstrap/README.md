# OpenShift Virtualization Operator Bootstrap

Installs the OpenShift Virtualization operator.

Use this module when you want GitOps to create the operator namespace, `OperatorGroup`, and `Subscription`.

The default OLM channel is `stable`.

Keep it disabled until you have approved worker pool and storage settings for virtualization.
