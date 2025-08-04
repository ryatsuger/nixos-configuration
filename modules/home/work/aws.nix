{ config, lib, pkgs, ... }: 

{
  # Install AWS CLI
  home.packages = with pkgs; [
    awscli2
  ];

  home.file.".aws/config".text = ''
    [profile workload-dev]
    sso_start_url = https://suger.awsapps.com/start
    sso_region = us-west-2
    sso_account_id = 821785902361
    sso_role_name = AdministratorAccess
    region = us-west-2
    output = json

    [profile workload-stag]
    sso_start_url = https://suger.awsapps.com/start
    sso_region = us-west-2
    sso_account_id = 651501331184
    sso_role_name = AdministratorAccess
    region = us-west-2
    output = json

    [profile workload-prod]
    sso_start_url = https://suger.awsapps.com/start
    sso_region = us-west-2
    sso_account_id = 752785145360
    sso_role_name = AdministratorAccess
    region = us-west-2
    output = json

    [profile marketplace-seller]
    sso_start_url = https://suger.awsapps.com/start
    sso_region = us-west-2
    sso_account_id = 530410124600
    sso_role_name = AdministratorAccess
    region = us-east-1
    output = json

    [profile suger-public]
    sso_start_url = https://suger-public.awsapps.com/start
    sso_region = us-west-2
    sso_account_id = 202111257067
    sso_role_name = AdministratorAccess
    region = us-west-2
    output = json
  '';
}