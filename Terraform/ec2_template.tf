# provision config later

data "cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  # part {
  #   content_type = "text/cloud-config"
  #   filename     = "cloud-config_provision.yaml"
  #   content      = local.provision_config
  #   }

  part {
    content_type = "text/x-shellscript"
    filename     = "setup_dependencies.sh"
    content  = <<-EOF
      #!/bin/bash

      sudo apt update && sudo apt upgrade -y
      echo "done"
      sudo apt-get install ffmpeg -y
      sudo apt  install awscli -y

      sudo apt install python3-pip -y
      pip3 install boto3

      sudo wget https://github.com/shaka-project/shaka-packager/releases/download/v2.6.1/packager-linux-x64  -O /bin/packager
      sudo chmod +x /bin/packager

      echo "for faster/visual confirmation of above execution.."
      wget https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4 -O /home/ubuntu/I_RAN.mp4
    EOF
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${local.resource_component}-profile"
  role = "${aws_iam_role.ec2_role.name}"
}

resource "aws_launch_template" "machine_template" {
  name                  = "test-min-template" 
  # name_prefix           = "test-min-ins-temp"
  image_id              = "${var.instance_ami}"
  instance_type         = "${var.instance_type}"
  key_name              = "${var.ssh_key}"
  # user_data             = data.cloudinit_config.config.rendered

  iam_instance_profile {
    name = "${aws_iam_instance_profile.instance_profile.name}"
  }

  tags = {
    Name = local.resource_component
  }

  monitoring {
    enabled = true
  }

}


resource "aws_autoscaling_group" "asg" {
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b"]
  desired_capacity   = 1
  max_size           = 1
  min_size           = 1

  launch_template {
    id      = "${aws_launch_template.machine_template.id}"
    # '$Latest', '$Default', numeric
    version = "$Latest"
  }
}