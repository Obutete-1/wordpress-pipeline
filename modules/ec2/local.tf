locals {
  ec2_userdata_script = templatefile("${path.module}/scripts/user_data.sh.tpl", {
  })
}
