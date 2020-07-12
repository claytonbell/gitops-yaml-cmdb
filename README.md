# gitops-yaml-cmdb

## status

work-in-progress

## overview

Simple yaml file CMDB

CI scripts
Environment files

## get a value from the yaml cmdb

```
gitops-yaml-cmdb
  [--get key [..]]     get a value from the cmdb.  Defaults to getting all values
  --format=<kind>      output format json, yaml, bash, bash-export, default yaml
  --override var=blah  variables on the command line override those found in the yaml files
  --exec -- /bin/bash  run a command with environment setup
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

deployment_role: arn:sdfs:sddsdfsf
```


## public api

```ruby
GitopsCmdb.file_load('file.yaml')
```

This will return all values.