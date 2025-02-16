```terraform
locals {
  list01 = [
    {
      name = "ABCD"
      id   = "1234"
    },
    {
      name = "EFGH"
      id   = "5678"
    },
    {
      name = "IJKL"
      id   = ""
    }
  ]

  map01 = {
    object01 = {
      name = "ABCD"
      id   = "1234"
    }
    object02 = {
      name = "EFGH"
      id   = "5678"
    }
    object03 = {
      name = "IJKL"
      id   = ""
    }
  }
}

output "list01_id" {
  value = flatten(local.list01.*.id)
}

output "map01_id" {
  value = flatten([
    for k, v in local.map01 : [
      v.id
    ] if v.id != ""
  ])
}
```
#### OUTPUTS:
```terraform
list01_id = [
  "1234",
  "5678",
  "",
]
map01_id  = [
  "1234",
  "5678",
]
```
