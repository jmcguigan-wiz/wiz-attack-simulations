output "sensor_attack_simulation" {
  description = "AWS CLI command to run the ECS task"
  value       = <<-EOT
  # Run the following command to execute the attack scenario 
  TASK_ID=$(aws ecs run-task \
    --cluster ${aws_ecs_cluster.wiz_ecs_cluster.name} \
    --task-definition ${aws_ecs_task_definition.wiz_fargate_attack_scenario_task_def.family}:${aws_ecs_task_definition.wiz_fargate_attack_scenario_task_def.revision} \
    --network-configuration "awsvpcConfiguration={subnets=[${aws_subnet.public_subnet_1.id},${aws_subnet.public_subnet_2.id}],securityGroups=[${aws_security_group.allow_wiz.id}],assignPublicIp=ENABLED}" \
    --launch-type FARGATE \
    --enable-execute-command \
    --region ${var.aws_region} \
    --query "tasks[0].taskArn" \
    --output text \
    | cut -d "/" -f 3)
  
  # Allow the scenario to run for 5 minutes before continuing. Your task may self-terminate after 5-10 minutes. This is okay and expected as long as the events still populate.
  
  # If the task hasn't stopped after 10 minutes, run the following command to stop it. When an ECS container stops its downloaded files are destroyed and are no longer accessible.
  aws ecs stop-task  \
    --cluster ${aws_ecs_cluster.wiz_ecs_cluster.name} \
    --region ${var.aws_region} \
    --task $TASK_ID
  EOT
}
output "redteam_attack_simulation" {
  description = "AWS CLI command to run the ECS task"
  value       = <<-EOT
  # Run the following command to start the attack container
  TASK_ID=$(aws ecs run-task \
    --cluster ${aws_ecs_cluster.wiz_ecs_cluster.name} \
    --task-definition ${aws_ecs_task_definition.wiz_aws_redteam_simulation.family}:${aws_ecs_task_definition.wiz_aws_redteam_simulation.revision} \
    --network-configuration "awsvpcConfiguration={subnets=[${aws_subnet.public_subnet_1.id},${aws_subnet.public_subnet_2.id}],securityGroups=[${aws_security_group.allow_wiz.id}],assignPublicIp=ENABLED}" \
    --launch-type FARGATE \
    --enable-execute-command \
    --region ${var.aws_region} \
    --query "tasks[0].taskArn" \
    --output text \
    | cut -d "/" -f 3)
  
  # Connect to the container to start the attack scenario
  aws ecs execute-command  \
    --cluster ${aws_ecs_cluster.wiz_ecs_cluster.name} \
    --task $TASK_ID \
    --container wiz-aws-redteam-simulation \
    --command "/bin/bash" \
    --interactive

  # Stop the ECS task once you have completed the attack simulation
  aws ecs stop-task  \
    --cluster ${aws_ecs_cluster.wiz_ecs_cluster.name} \
    --task $TASK_ID
  EOT
}