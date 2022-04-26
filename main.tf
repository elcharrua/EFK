## Validate workspace
locals {
 env = {
	network = {}
 }
  workspace_validate = merge(local.env["network"], local.env[terraform.workspace])
}

provider "google" {
  credentials = file("~/i365/credentials.json")
  project     = var.project
  region      = var.region
}

terraform {
  backend "gcs" {
    bucket  = "compasso-terraform-state"
    prefix  = ".terraform/terraform.state"
  }
}
resource "google_compute_network" "bff_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false

}

resource "google_compute_subnetwork" "bff_dev_k8s_sbn" {

  name          = var.sub_priv_dev_name
  ip_cidr_range = var.vpc_cidr_dev
  region        = var.region
  network       = google_compute_network.bff_vpc.id //referencia a VPC

    secondary_ip_range {
     range_name = var.cluster_secondary_range_name_dev //ips secundarios para os pods
     ip_cidr_range = var.pods_cidr_dev
   }

    secondary_ip_range {
     range_name = var.services_secondary_range_name_dev //ips secundarios para os serviços
     ip_cidr_range = var.services_cidr_dev
   }
}

resource "google_compute_subnetwork" "bff_hml_k8s_sbn" {

  name          = var.sub_priv_hml_name
  ip_cidr_range = var.vpc_cidr_hml
  region        = var.region
  network       = google_compute_network.bff_vpc.id //referencia a VPC

    secondary_ip_range {
     range_name = var.cluster_secondary_range_name_hml //ips secundarios para os pods
     ip_cidr_range = var.pods_cidr_hml
   }

    secondary_ip_range {
     range_name = var.services_secondary_range_name_hml //ips secundarios para os serviços
     ip_cidr_range = var.services_cidr_hml
   }
}

resource "google_compute_subnetwork" "bff_prd_k8s_sbn" {

  name          = var.sub_priv_prd_name
  ip_cidr_range = var.vpc_cidr_prd
  region        = var.region
  network       = google_compute_network.bff_vpc.id //referencia a VPC

    secondary_ip_range {
     range_name = var.cluster_secondary_range_name_prd //ips secundarios para os pods
     ip_cidr_range = var.pods_cidr_prd
   }

    secondary_ip_range {
     range_name = var.services_secondary_range_name_prd //ips secundarios para os serviços
     ip_cidr_range = var.services_cidr_prd
   }
}

resource "google_compute_subnetwork" "bastion" {
  name          = var.bastion_subnet
  ip_cidr_range = var.cidr_bastion_subnet
  region        = var.region
  network       = google_compute_network.bff_vpc.id //referencia a VPC

}

resource "google_compute_router" "router" {
  name    = var.router_name
  network = google_compute_network.bff_vpc.id //referencia a VPC
  bgp {
    asn            = 64514
    advertise_mode = "CUSTOM"
  }
}

resource "google_compute_address" "static_ip"{
  name = "nat-external-ip"
}


# NAT Gateway
# https://www.terraform.io/docs/providers/google/r/compute_router_nat.html
resource "google_compute_router_nat" "nat" {
  name                               = var.nat_name
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  nat_ips = [google_compute_address.static_ip.name]

  subnetwork {
    name                    = var.sub_priv_dev_name //sub-rede criada l-18
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]

  }
  
  subnetwork {
    name                    = var.sub_priv_hml_name //sub-rede criada l-18
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]

  }
  subnetwork {
    name                    = var.sub_priv_prd_name //sub-rede criada l-18
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]

  }
  
  depends_on = [google_compute_subnetwork.bff_dev_k8s_sbn, google_compute_subnetwork.bff_hml_k8s_sbn, google_compute_subnetwork.bff_prd_k8s_sbn, google_compute_address.static_ip]

}

resource "google_compute_firewall" "bff_ingress_controller_ports_dev" {
  name    = "bff-ingress-controller-ports-dev"
  network = google_compute_network.bff_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = ["10.1.40.0/28"] # Bloco de ips dos masters de DEV ver como sharear essa variavel entre workspaces ?

  target_tags = ["ingress-controller-fw-dev"]
}


resource "google_compute_firewall" "bff_ingress_controller_ports_hml" {
  name    = "bff-ingress-controller-ports-hml"
  network = google_compute_network.bff_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = ["10.1.44.0/28"] # Bloco de ips dos masters de HML ver como sharear essa variavel entre workspaces ?

  target_tags = ["ingress-controller-fw-hml"]
}

resource "google_compute_firewall" "bff_ingress_controller_ports_prd" {
  name    = "bff-ingress-controller-ports-prd"
  network = google_compute_network.bff_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }

  source_ranges = ["10.1.48.0/28"] # Bloco de ips dos masters de HML ver como sharear essa variavel entre workspaces ?

  target_tags = ["ingress-controller-fw-prd"]
}


resource "google_compute_firewall" "bastion_port" {
  name    = "bastion-port"
  network = google_compute_network.bff_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] 

  target_tags = ["bastion-fw-tag"]
}

resource "google_compute_firewall" "bastion_access_node_dev" {
  name    = "node-dev-bastion-access"
  network = google_compute_network.bff_vpc.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["10.1.36.0/28","10.1.40.0/28","10.1.44.0/28"] 

  target_tags = ["dev-node-fw-tag"]
}

# TODO firewall ingress de HML e PRD