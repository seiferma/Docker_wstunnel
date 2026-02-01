variable "VERSION_WSTUNNEL" {
  # renovate: datasource=github-releases depName=erebe/wstunnel
  default = "10.5.2"
}

variable "VERSION_TINI" {
  # renovate: datasource=github-releases depName=krallin/tini
  default = "0.19.0"
}

group "default" {
  targets = ["default"]
}

target "default" {
  platforms = ["linux/amd64", "linux/arm64"]
  tags = ["quay.io/seiferma/wstunnel:${VERSION_WSTUNNEL}", "quay.io/seiferma/wstunnel:latest"]
  args = {
    VERSION_WSTUNNEL = "${VERSION_WSTUNNEL}",
    VERSION_TINI = "${VERSION_TINI}"
  }
}

target "test" {
  inherits = ["default"]
  platforms = ["linux/amd64"]
  tags = ["test-image"]
}