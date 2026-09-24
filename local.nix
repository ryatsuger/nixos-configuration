{ ... }:

{
  # User account settings
  mySystem = {
    username = "ruiyang";
    userFullName = "Ruiyang Ke";
    userEmail = "ruiyang@suger.io";

    # git author for every repo on this machine. Personal, never the work
    # address: a work email here is attributed to the wrong GitHub account.
    # Work repos override it per-clone with `git config user.email ...`.
    gitUserName = "ruiyangke";
    gitUserEmail = "me@ry.ke";
    
    # SSH authorized keys for this machine
    ssh.authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEwlsSEv+WqQUe57qtGblgiWrd7D7g5G6BX3SSFP4CXl ruiyangsmacnixos"
    ];
  };
}