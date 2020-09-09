{ pkgs, ... }:

{
  environment = {
    etc = {
      "containers/policy.json" = {
        mode="0644";
        text=''
          {
            "default": [{ "type": "insecureAcceptAnything" }],
            "transports": {
              "docker-daemon": {
                "": [{ "type": "insecureAcceptAnything" }]
              }
            }
          }
        '';
      };

      "containers/registries.conf" = {
        mode = "0644";
        text = ''
          [registries.search]
          registries = ['docker.io', 'quay.io']
        '';
      };
    };

    systemPackages = with pkgs; [
      conmon
      fuse-overlayfs
      podman
      runc
      slirp4netns
    ];
  };

  users.users.alex = {
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };
}
