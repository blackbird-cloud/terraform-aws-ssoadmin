output "users" {
  value       = module.users.users
  description = "The created users within Identity Store."
}

output "groups" {
  value       = module.groups.groups
  description = "The created groups within Identity Store."
}
