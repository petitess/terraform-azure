prefix = "infra-test"
env = "test"
location = "swedencentral"
tags = {
  Environment = "Test"
  Application = "Infra"
}

st = {
"01" = {
    name = "stasusnowtest01"
    kind = "StorageV2"
    public_access = true
    public_networks = "Allow"
    replication = "LRS"
    tier = "Standard"
    versioning_enabled = false
    containers = [
        {name = "container1"}
    ]
    fileshares = [
        {name = "fileshare01"}
    ]
    queues = []
    tables = []
}
"02" = {
    name = "stasusnowtest02"
    kind = "StorageV2"
    public_access = true
    public_networks = "Allow"
    replication = "LRS"
    tier = "Standard"
    versioning_enabled = false
    containers = []
    fileshares = [
        {name = "fileshare01"},
        {name = "fileshare02"}
    ]
    queues = [
        "queue01"
    ]
    tables = [
        "table01"
    ]
}
}