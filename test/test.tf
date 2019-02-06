resource "aws_vpc" "foo" {
  cidr_block = "10.1.0.0/16"
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "foo" {
  vpc_id            = "${aws_vpc.foo.id}"
  cidr_block        = "10.1.1.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_subnet" "bar" {
  vpc_id            = "${aws_vpc.foo.id}"
  cidr_block        = "10.1.2.0/24"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

resource "aws_alb" "foo" {
  internal = true
  subnets  = ["${aws_subnet.foo.id}", "${aws_subnet.bar.id}"]
}

module "test-lb-waf" {
  source = "../"

  load_balancer_arn = "${aws_alb.foo.arn}"

  whitelist = [
    {
      type  = "IPV4"
      value = "127.0.0.1/32"
    },
    {
      type  = "IPV4"
      value = "127.0.0.2/32"
    },
  ]
}
