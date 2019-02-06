# Summary

Terraform module to setup WAF for Load Balancers.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| environment | Environment name. | string | `test` | no |
| load\_balancer\_arn | ARN of Load Balancer to assign this WAF | string | - | yes |
| project | Project name. | string | `project` | no |
| resource\_identifier | By default resource identifier is a sum of project name and environment name. This variable allows tooverride this with custom name. | string | `none` | no |
| whitelist | List of IP's (in CIDR format) to whitelist | list | `<list>` | no |