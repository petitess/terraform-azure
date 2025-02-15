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
  }
}

output "list01" {
  value = local.list01
}

output "list01_id" {
  value = flatten(local.list01.*.id)
}

output "map01" {
  value = local.map01
}

output "map01_id" {
  value = flatten([
    for k, sca in local.map01 : [
      sca.id
    ]
  ])
}
```
#### OUTPUTS:
```
list01 = [
  {
      id   = "1234"
      name = "ABCD"
  },
  {
      id   = "5678"
      name = "EFGH"
  },
]
list01_id = [
    "1234",
    "5678",
]
map01 = {
  object01 = {
      id   = "1234"
      name = "ABCD"
  }
  object02 = {
      id   = "5678"
      name = "EFGH"
  }
}
map01_id = [
    "1234",
    "5678",
]
```
