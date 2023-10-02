# --- 5-update-partners-info-yaml/files.tf ---

data "local_file" "config_context_sh" {
  filename = "${var.env_dir_path}/config-context.sh"
}

resource "local_file" "github_info_yaml" {
  filename = "${path.module}/github.info.yaml"

  content = templatefile("${path.module}/templates/github.info.yaml.tftpl", { read_write_token = var.github_read_write_token })
}

resource "local_file" "update_partners_info_yaml" {
  filename = "${local.tmp_folder_path}/update-partners.info.yaml"

  content = templatefile("${path.module}/templates/update-partners.info.yaml.tftpl", { peers = local.update_partners_peers })
}

resource "local_file" "values_yaml" {
  filename = "${path.module}/values.yaml"

  content = templatefile("${path.module}/templates/values.yaml.tftpl", { region_name = data.aws_region.main.name })
}
