{ ... }:

{
  # User account settings
  mySystem = {
    username = "ruiyang";
    userFullName = "Ruiyang Ke";
    userEmail = "ruiyang@suger.io";
    
    # SSH authorized keys for this machine
    ssh.authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEwlsSEv+WqQUe57qtGblgiWrd7D7g5G6BX3SSFP4CXl ruiyangsmacnixos"
    ];
  };
}