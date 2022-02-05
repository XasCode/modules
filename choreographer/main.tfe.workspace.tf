resource "tfe_workspace" "workspace" {
  count                 = contains(var.envs, var.environment) ? length(var.managed) : 0

  name                  = "${var.tf_org}-${var.managed[count.index].name}-${var.environment}"
  organization          = var.tf_org
  auto_apply            = true
  file_triggers_enabled = false
  queue_all_runs        = true
  speculative_enabled   = false
  working_directory     = "terraform"
  vcs_repo {
    identifier         = data.github_repository.repository[count.index].full_name
    branch             = local.branch
    ingress_submodules = false
    oauth_token_id     = tfe_oauth_client.xascode[count.index].oauth_token_id
  }
}

resource "tfe_variable" "gc" {
  count                 = contains(var.envs, var.environment) ? length(var.managed) : 0
  key                   = "GOOGLE_CREDENTIALS"
  value                 = trimspace(replace(base64decode(google_service_account_key.mykey[count.index].private_key),"\n",""))
  category              = "env"
  workspace_id          = tfe_workspace.workspace[count.index].id
  sensitive             = true
}

resource "tfe_variable" "environment" {
  count                 = contains(var.envs, var.environment) ? length(var.managed) : 0
  key                   = "environment"
  value                 = var.environment
  category              = "terraform"
  workspace_id          = tfe_workspace.workspace[count.index].id
}

resource "tfe_variable" "project" {
  count                 = contains(var.envs, var.environment) ? length(var.managed) : 0
  key                   = "project"
  value                 = replace(jsonencode(var.managed[count.index]), "/(\".*?\"):/", "$1 = ")
  category              = "terraform"
  workspace_id          = tfe_workspace.workspace[count.index].id
  hcl                   = true
}

resource "tfe_variable" "tf_org" {
  count                 = contains(var.envs, var.environment) ? length(var.managed) : 0
  key                   = "tf_org"
  value                 = var.tf_org
  category              = "terraform"
  workspace_id          = tfe_workspace.workspace[count.index].id
}

resource "tfe_variable" "organization_name" {
  count                 = contains(var.envs, var.environment) ? length(var.managed) : 0
  key                   = "organization_name"
  value                 = var.organization_name
  category              = "terraform"
  workspace_id          = tfe_workspace.workspace[count.index].id
}

resource "tfe_oauth_client" "xascode" {
  count            = contains(var.envs, var.environment) ? length(var.managed) : 0

  organization     = lower(var.gh_org)
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.gh_token
  service_provider = "github"
}
