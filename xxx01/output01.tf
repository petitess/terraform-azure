locals {
  env = "dev"
  sp = {
    dev = {
      a1 = "gdg34r53"
      a2 = "wsfwef"
      a3 = "yth564t54rtf"
      a4 = ""
    }
  }
  object = {
    dev = {
      a1 = { grp : "gdg34r53", wse : "sdv" }
      a2 = { grp : "gdg76553", wse : "s34dv" }
      a3 = { grp : "gd2354r53", wse : "sd53v" }
      a4 = { grp : "gddr53", wse : "" }
      a5 = { grp : "duplicate", wse : "" }
      a6 = { grp : "duplicate", wse : "sdv" }
    }
  }
}

output "abc" {
  value = {
    for x in local.sp[local.env] : x => x if x != ""
  }
}

output "def" {
  value = {
    for x in local.object[local.env] : x.grp => x.wse if x.wse != ""
  }
}

output "fgh" {
  value = {
    for x in local.object[local.env] : x.grp => x.wse... #if x.wse != ""
  }
}
