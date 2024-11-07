resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name                = "scale-up-alarm-${var.unique_suffix}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "5"
  alarm_description         = "Scale up when average CPU usage is >= 5%"
  alarm_actions             = [aws_autoscaling_policy.scale_up_policy.arn]
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name                = "scale-down-alarm-${var.unique_suffix}"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "3"
  alarm_description         = "Scale down when average CPU usage is <= 3%"
  alarm_actions             = [aws_autoscaling_policy.scale_down_policy.arn]
  insufficient_data_actions = []
}
