# gitops-yaml-cmdb

## overview 

Simple YAML file CMDB, designed for CI builds & testing

* gitops compatible
* simple file inheritance, so you can DRY and organize your YAML files
* supports mustache `{{ }}` and OS environment variables `${ }` templating
* use it with any build or app (doesn't have to be kubernetes)

This project was born out of the need to manage 1000+ microservices and
3000+ CI builds. The variety of build scripts, environment config and value
templating was troublesome.  

## get a value from the yaml cmdb

```
gitops-yaml-cmdb
  --get key [--get key [..]]  get a value from the cmdb
  --format=<kind> json, yaml, bash, bash-export
  --override var=blah
  --exec -- sush 
```

## file format

```yaml
---

includes:
  - ./aws/common.yaml
  - ./aws/prod-us-west-1.yaml
  - ./application/my_app.yaml

variables:
  BUILD_NUMBER: ${BUILDKITE_BUILD_NUMBER}
  app_threads: 4

deployment_role: arn:sdfs:sddsdfsf
```

## public api

```ruby
GitopsCmdb.file_load('file.yaml')
```

This will return all values.
