## This is for my personal use. ##
Run `nix build` to see the patched nerd-fonts inside results/

In my nixos-config, this is how I install the fonts:
```nix
fonts = {
    packages = with pkgs; [
        inputs.sf-mono-nf.packages.${pkgs.system}.default
        # Other fonts alongside SFMono
        nerd-fonts.meslo-lg
        nerd-fonts.hack
    ];
};
```
