```terraform
locals {
  my_list = [
    {
      city : "London"
      weather : "sunny"
    },
    {
      city : "Berlin"
      weather : "rainy"
    },
    {
      city : "Malmo"
      weather : "rainy"
    }
  ]
}

output "weather" {
  value = {
    for s in distinct(flatten(local.my_list.*.weather)) : s => s
    if s != null
  }
}
```
#### OUTPUT:
```
 weather = {
        rainy = "rainy"
        sunny = "sunny"
     }
```
