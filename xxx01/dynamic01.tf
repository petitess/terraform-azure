dynamic "origin_group" {
    for_each = var.load_balancer_origin_groups
    iterator = outer_block
    content {
      name = outer_block.key
      dynamic "origin" {
        for_each = outer_block.value.origins
        iterator = inner_block
        content {
          hostname = inner_block.value.hostname
        }
      }
    }
  }
