prefix   = "infra-test"
env      = "test"
location = "swedencentral"
tags = {
  Environment = "Test"
  Application = "Infra"
}

st = {
  "01" = {
    name               = "stasusnowtest01"
    kind               = "StorageV2"
    public_access      = true
    public_networks    = "Allow"
    replication        = "LRS"
    tier               = "Standard"
    versioning_enabled = false
    containers = [
      { name = "container1" }
    ]
    fileshares = [
      { name = "fileshare01", quotaGB = 10, backup = true }
    ]
    queues = []
    tables = []
  }
  "02" = {
    name               = "stasusnowtest02"
    kind               = "StorageV2"
    public_access      = true
    public_networks    = "Allow"
    replication        = "LRS"
    tier               = "Standard"
    versioning_enabled = false
    containers         = []
    fileshares = [
      { name = "fileshare01", quotaGB = 10, backup = true },
      { name = "fileshare02", quotaGB = 10, backup = false }
    ]
    queues = [
      "queue01"
    ]
    tables = [
      "table01"
    ]
  }
}
