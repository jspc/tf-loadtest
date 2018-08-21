tf-loadtest
==

Spin up a go-lo environment in Digital Ocean to run tests against.

Note: this project is for demonstration- it has some lazily hardcoded paths in userdata that you wont like.

## Usage

You will need the following env vars set:

```bash
export TF_VAR_domain=<your digital ocean domain name>
export TF_VAR_do_token=<digital ocean token>
export TF_VAR_tls_private_key=<path to tls private key>
export TF_VAR_tls_cert=<path to tls cert>
export TF_VAR_tls_chain=<path to tls cert chain- can be empty file>

export TF_VAR_ssh_private_key=<path to ssh key>
export TF_VAR_ssh_public_key=<path to ssh publc key>
```

From there:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

You can tear the cluster down with

```bash
$ terraform destroy
```

## Interacting with cluster

### Scheduling

See: http://github.com/go-lo/golo-cli

You can interact with this cluster by:

1. Setting `DO_TOKEN` to the token used above
1. Passing the flag `-provider digitalocean`, and
1. Passing the flag `-agent-tag agent`

### Seeing results

Opening: http://influx.your-domain:8888, where `your-domain` is the domain name from the env var `$TF_VAR_domain` as set above, will take you to chronograf and let you see your results.

You can view this quickly in the Data Explorer tab on the left. A sample query would be:

```
SELECT count("duration") AS "count_duration" FROM "simple_job_runner"."autogen"."request" WHERE time > now() - 1h AND "error"='false' GROUP BY time(1s) FILL(null)
```

Which would show:

1. Requests per second
1. Over the last hour
1. On the schedule `simple_job_runner`
