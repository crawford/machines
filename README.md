# Machines

These are the Nix derivations for my machines, with common functionality broken up into modules.

## Setup

Add the channel:

    sudo nix-channel --add https://github.com/crawford/machines/archive/main.tar.gz machines

Reference the modules:

```nix
{
	imports = [
		./hardware-configuration.nix
		<machines/deepwater.nix>
	];
	# ...
}
```

## Update

Update the channel:

    sudo nix-channel --update machines

Rebuild:

    sudo nixos-rebuild switch
