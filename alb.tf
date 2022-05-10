resource "aws_lb" "main" {
  count                            = var.enable ? 1 : 0
  name                             = module.labels.id #optional
  internal                         = var.internal #optional if true alb will be internal
  load_balancer_type               = var.load_balancer_type #optional, to create a type of lb (network,gateway,application)
  security_groups                  = var.security_groups #(Optional) A list of security group IDs to assign to the LB. Only valid for Load Balancers of type application
  subnets                          = var.subnets # (Optional) A list of subnet IDs to attach to the LB. Subnets cannot be updated for Load Balancers of type network. Changing this value for load balancers of type network will force a recreation of the resource.
  enable_deletion_protection       = var.enable_deletion_protection #(Optional) If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false
  idle_timeout                     = var.idle_timeout #(Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60.
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing #(Optional) If true, cross-zone load balancing of the load balancer will be enabled. This is a network load balancer feature. Defaults to false
  enable_http2                     = var.enable_http2 #(Optional) Indicates whether HTTP/2 is enabled in application load balancers. Defaults to true
  ip_address_type                  = var.ip_address_type #(Optional) The type of IP addresses used by the subnets for your load balancer. The possible values are ipv4 and dualstack
  tags                             = module.labels.tags #Optional) A map of tags to assign to the resource
  drop_invalid_header_fields       = true #(Optional) Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). The default is false. 


  timeouts {
    create = var.load_balancer_create_timeout #(Default 10 minutes) Used for Creating LB
    delete = var.load_balancer_delete_timeout #(Default 10 minutes) Used for LB modifications
    update = var.load_balancer_update_timeout #(Default 10 minutes) Used for destroying LB
  }
  access_logs {
    enabled = var.access_logs #(Optional) Boolean to enable / disable access_logs. Defaults to false, even when bucket is specified
    bucket  = var.log_bucket_name #(Required) The S3 bucket name to store the logs in.
    prefix  = module.labels.id #(Optional) The S3 bucket prefix. Logs are stored in the root if not configured.
  }
  dynamic "subnet_mapping" {
    for_each = var.subnet_mapping

    content {
      subnet_id     = subnet_mapping.value.subnet_id #(Required) The id of the subnet of which to attach to the load balancer. You can specify only one subnet per Availability Zone.
      allocation_id = lookup(subnet_mapping.value, "allocation_id", null) #(Optional) The allocation ID of the Elastic IP address.
    }
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn #(Required, Forces New Resource) ARN of the load balancer.
  port              = "80" #(Optional) Port on which the load balancer is listening. Not valid for Gateway Load Balancers.
  protocol          = "HTTP" #(Optional) Protocol for connections from clients to the load balancer. For Application Load Balancers, valid values are HTTP and HTTPS, with a default of HTTP.


  default_action {
    type = "redirect" #(Required) Type of routing action. Valid values are forward, redirect, fixed-response, authenticate-cognito and authenticate-oidc

    redirect {
      port        = "443" #Optional) Port. Specify a value from 1 to 65535 or #{port}. Defaults to #{port}.
      protocol    = "HTTPS" #(Optional) Protocol. Valid values are HTTP, HTTPS, or #{protocol}. Defaults to #{protocol}
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "Example" {
  name        = "tf-example-lb-tg" #Optional, Forces new resource Name of the target group.
  target_type = "alb"  #REQUIRED
  port        = 80 #Port on which targets receive traffic, unless overridden when registering a specific target.
  protocol    = "TCP" #Protocol to use for routing traffic to the targets. 
  vpc_id      = aws_vpc.main.id #Identifier of the VPC in which to create the target group.
}