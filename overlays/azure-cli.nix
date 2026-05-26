# Fix `az login` crashing with:
#   TypeError: Session.request() got an unexpected keyword argument 'claims_challenge'
#
# Root cause: azure-cli 2.79.0 (nixos-25.11) requires `msal==1.34.0b1`, whose
# `initiate_device_flow()` consumes the `claims_challenge` kwarg. nixpkgs ships
# msal 1.33.0, which does not — it forwards the kwarg down into
# requests.Session.request(), raising TypeError. Every `az login` path passes
# claims_challenge, so all interactive/device/SP logins break.
#
# Fix: bump msal to 1.34.0 (same dependency set as 1.33.0, no cascade).
# Uses pythonPackagesExtensions so the override also reaches azure-cli's
# private python set (it does `python3.override { packageOverrides = ...; }`,
# which would drop a plain top-level override but still composes extensions).
final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (pyfinal: pyprev: {
      msal = pyprev.msal.overridePythonAttrs (_old: {
        version = "1.34.0";
        src = pyprev.fetchPypi {
          pname = "msal";
          version = "1.34.0";
          hash = "sha256-drqDtxbqWm11sCecCsNToOBbggyh9mgsDrf0UZDEPC8=";
        };
      });
    })
  ];
}
