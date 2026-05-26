locals {
  tags = {
    environment = var.environment
    purpose     = "nixos-dev"
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "nixos" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

# --- Storage for the uploaded VHD -------------------------------------------

# Storage account names must be globally unique, 3-24 lowercase alphanumerics.
resource "random_string" "sa_suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "azurerm_storage_account" "images" {
  name                     = "nixosimg${random_string.sa_suffix.result}"
  resource_group_name      = azurerm_resource_group.nixos.name
  location                 = azurerm_resource_group.nixos.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = local.tags
}

resource "azurerm_storage_container" "images" {
  name                  = "vhds"
  storage_account_id    = azurerm_storage_account.images.id
  container_access_type = "private"
}

# Upload the locally-built fixed-size VHD as a page blob.
resource "azurerm_storage_blob" "nixos_vhd" {
  name                   = "nixos-${var.environment}.vhd"
  storage_account_name   = azurerm_storage_account.images.name
  storage_container_name = azurerm_storage_container.images.name
  type                   = "Page"
  source                 = var.vhd_local_path
}

# Register the uploaded VHD as a managed image.
resource "azurerm_image" "nixos" {
  name                = "nixos-${var.environment}"
  resource_group_name = azurerm_resource_group.nixos.name
  location            = azurerm_resource_group.nixos.location
  hyper_v_generation  = var.hyper_v_generation
  tags                = local.tags

  os_disk {
    os_type      = "Linux"
    os_state     = "Generalized"
    blob_uri     = azurerm_storage_blob.nixos_vhd.url
    storage_type = "Standard_LRS"
  }
}

# --- Networking --------------------------------------------------------------

resource "azurerm_virtual_network" "nixos" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.nixos.location
  resource_group_name = azurerm_resource_group.nixos.name
  tags                = local.tags
}

resource "azurerm_subnet" "nixos" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.nixos.name
  virtual_network_name = azurerm_virtual_network.nixos.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "nixos" {
  name                = "${var.vm_name}-pip"
  location            = azurerm_resource_group.nixos.location
  resource_group_name = azurerm_resource_group.nixos.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# NSG replaces the GCE cloud firewall. The in-VM firewall is disabled in the
# NixOS host, so all inbound control happens here.
resource "azurerm_network_security_group" "nixos" {
  name                = "${var.vm_name}-nsg"
  location            = azurerm_resource_group.nixos.location
  resource_group_name = azurerm_resource_group.nixos.name
  tags                = local.tags

  security_rule {
    name                       = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }

  # Mirror the dev port range opened in modules/nixos/core/networking.nix.
  security_rule {
    name                       = "allow-dev-ports"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000-9000"
    source_address_prefix      = var.allowed_ssh_cidr
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nixos" {
  name                = "${var.vm_name}-nic"
  location            = azurerm_resource_group.nixos.location
  resource_group_name = azurerm_resource_group.nixos.name
  tags                = local.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.nixos.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nixos.id
  }
}

resource "azurerm_network_interface_security_group_association" "nixos" {
  network_interface_id      = azurerm_network_interface.nixos.id
  network_security_group_id = azurerm_network_security_group.nixos.id
}

# --- Virtual machine ---------------------------------------------------------

resource "azurerm_linux_virtual_machine" "nixos" {
  name                  = var.vm_name
  resource_group_name   = azurerm_resource_group.nixos.name
  location              = azurerm_resource_group.nixos.location
  size                  = var.vm_size
  admin_username        = var.nixos_username
  network_interface_ids = [azurerm_network_interface.nixos.id]
  source_image_id       = azurerm_image.nixos.id
  tags                  = local.tags

  # The image already bakes the user + SSH key (local.nix); this provisions
  # the same admin user consistently through waagent.
  admin_ssh_key {
    username   = var.nixos_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }
}
