locals {
  userdata_script = templatefile("${path.module}/scripts/asg_user_data.sh.tpl", {
  })
}
