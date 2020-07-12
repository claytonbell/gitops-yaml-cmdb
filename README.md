# gitops-yaml-cmdb

Simple yaml file CMDB

CI scripts
Environment files

gitops-yaml-cmdb
  --get key [--get key [..]]  get a value from the cmdb
  --format=<kind> json, yaml, bash, bash-export
  --override var=blah
  --exec -- sush 

## file format

```yaml
---

includes:
  - file://aws/common.yaml
  - file://aws/prod-us-west-1.yaml
  - file://application/my_app.yaml

variables:
  BUILD_NUMBER: ${BUILDKITE_BUILD_NUMBER}

deployment_role: arn:sdfs:sddsdfsf
```

## lib

GitopsCmdb.load('file.yaml')
